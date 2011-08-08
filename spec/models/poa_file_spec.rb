require 'spec_helper'

describe PoaFile do

  context "when defining a PoaFile" do
    it "should specify a record length of 80" do
      PoaFile.record_length.should == 80
    end

    it "should specify an extension of 'fbc'" do
      PoaFile.ext.should == ".fbc"
    end

    it "should define a file mask of '*.fbc'" do
      PoaFile.file_mask.should == "*.fbc"
    end
  end

  context "when working with remote files" do
    before(:all) do
      @sample_file = '02000011697978     INGRAM       110808RTYRHHB-110808183846.FF030000000     1    1100002             R403156745            20N273016979780110808110808110808     2100003R403156745            THANK YOU FOR YOUR ORDER.  IF YOU REQUIRE ASSISTAN 2100004R403156745            CE, PLEASE CONTACT OURELECTRONIC ORDERING DEPARTME 2100005R403156745            NT AT 1-800-234-6737 OR VIA EMAIL AT        FLASHB 2100006R403156745            ACK@INGRAMBOOK.COM.  TO CANCEL AN ORDER, PLEASE SP 2100007R403156745            EAK WITH AN     ELECTRONIC ORDERING REPRESENTATIVE 2100008R403156745             AT 1-800-234-6737.                                4000009R403156745            219                   9780373200009       00100100C4100010R403156745            000 000000{ 0000 0000 0000 0000 0000 0000 0000     4200011R403156745            HQPB FAMOUS FIRSTS MATCHMAKERSMACOMBER DEBBIE     M4300012R403156745            HQPB                030900019350000000010000000    4400013R403156745                                00004.99EN00003.240000001      4500014R403156745            219                                                5900015R403156745            0001300000000010000000001000000000400000000000000011100016             R327866855            20N273016979780110808110808110808     2100017R327866855            THANK YOU FOR YOUR ORDER.  IF YOU REQUIRE ASSISTAN 2100018R327866855            CE, PLEASE CONTACT OURELECTRONIC ORDERING DEPARTME 2100019R327866855            NT AT 1-800-234-6737 OR VIA EMAIL AT        FLASHB 2100020R327866855            ACK@INGRAMBOOK.COM.  TO CANCEL AN ORDER, PLEASE SP 2100021R327866855            EAK WITH AN     ELECTRONIC ORDERING REPRESENTATIVE 2100022R327866855             AT 1-800-234-6737.                                4000023R327866855            220                   9780373200009       00100100C4100024R327866855            000 000000{ 0000 0000 0000 0000 0000 0000 0000     4200025R327866855            HQPB FAMOUS FIRSTS MATCHMAKERSMACOMBER DEBBIE     M4300026R327866855            HQPB                030900040350000000010000000    4400027R327866855                                00004.99EN00003.240000001      4500028R327866855            220                                                5900029R327866855            0001300000000010000000001000000000400000000000000019100030000000000000200002000000000200001000020001200000000120000200001'
    end


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
        @ftp.stub(:delete).and_return(nil)
        @client.stub(:connect).and_yield(@ftp)
      end

      it "should count only the files ending with .fbc" do
        PoaFile.remote_files.size.should == 1
      end

      context "file is downloaded" do

        before(:each) do
          @file_name = 'hb-110803182629.fbc'
          poa_file = PoaFile.create_path(@file_name)
          @ftp.should_receive(:gettextfile).with(@file_name, poa_file).and_return do
            file = File.new(poa_file, 'w')
            file.write @sample_file
            file.close
            nil
          end
        end


        it "should download the file, create a PaoFile record, and delete the file from the server" do

          PoaFile.needs_import.count.should == 0
          PoaFile.download.size.should == 1
          PoaFile.needs_import.count.should == 1
          PoaFile.needs_import.first.file_name.should == @file_name
        end


        it "should have 80 chars in each line" do
          PoaFile.download.size.should == 1
          PoaFile.needs_import.first.data.split(/\n/).each do |line|
            line.chomp.length.should == 80
          end
        end
      end


      context "and a POA file with the same name has already been downloaded" do
        before(:each) do
          file_name = 'hb-110803182629.fbc'
          @ftp.stub(:gettextfile).with(file_name, PoaFile.create_path(file_name))
          PoaFile.download
        end

        it "should make the existing PoaFile old version the new file" do
          pending

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
