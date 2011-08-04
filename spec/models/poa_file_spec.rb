require 'spec_helper'

describe PoaFile do

  context "when working with remote files" do
    before(:each) do
      @client = double('CdfFtpClient')
      CdfFtpClient.stub(:new).and_return(@client)
    end

    context "and there are no POA files on the server" do
      it "should count 0 files" do
        @client.should_receive(:connect)
        PoaFile.remote_files.count.should == 0
      end
    end

    context "and there is 1 POA files on the server" do
      before(:each) do
        @outgoing_files = [
            "drw-rw-rw-   1 user     group           0 Aug  3 21:52 ..",
            "drw-rw-rw-   1 user     group           0 Aug  3 21:52 .",
            "-rw-rw-rw-   1 user     group         128 Aug  3 13:30 hb-110803182629.fbc",
            "-rw-rw-rw-   1 user     group        1872 Aug  3 20:30 hb-110804012651.fbo"
        ]

        @ftp = double('ftp-server')
        @ftp.stub(:chdir).with('outgoing').and_return(nil)
        @ftp.stub(:list).with('*.fbc').and_return(@outgoing_files)
        @client.stub(:connect).and_yield(@ftp)
      end

      it "should count only the files ending with .fbc" do
        PoaFile.remote_files.size.should == 1
      end

      it "should download the file, create a PaoFile record, and delete the file from the server" do
        file_name = 'hb-110803182629.fbc'
        @ftp.should_receive(:gettextfile).with(file_name, PoaFile.create_path(file_name))
        PoaFile.needs_import.count.should == 0
        PoaFile.download.size.should == 1
        PoaFile.needs_import.count.should == 1
        PoaFile.needs_import.first.file_name.should == file_name
      end

      context "and a POA file with the same name has already been downloaded" do
        before(:each) do
          file_name = 'hb-110803182629.fbc'
          @ftp.stub(:gettextfile).with(file_name, PoaFile.create_path(file_name))
          PoaFile.download
        end

        it "should make the existing PoaFile old version the new file" do
          file_name = 'hb-110803182629.fbc'
          @ftp.stub(:gettextfile).with(file_name, PoaFile.create_path(file_name))
          PoaFile.download
        end
      end
    end
  end

  context "when importing files" do

    context "and there are no POA files to import" do
      it "should have no files that need import" do
        PoaFile.needs_import.count.should == 0
      end
    end

    context "and there are POA files to import" do
      it "should have count files that need import" do
        not_yet_imported = Factory(:poa_file)
        PoaFile.needs_import.count.should == 1

        imported = Factory(:poa_file, :imported_at => Time.now)
        PoaFile.count.should == 2
        PoaFile.needs_import.count.should == 1
      end
    end

  end


end
