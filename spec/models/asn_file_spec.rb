require "spec_helper"

describe AsnFile do

  before(:all) do
    AsnFile.all.each &:destroy
  end

  after(:all) do
    AsnFile.all.each &:destroy
  end

  context "when defining an Asnfile" do
    it "should specify a record length of 200" do
      AsnFile.record_length.should == 200
    end

    it "should specify an extension of 'PBS'" do
      AsnFile.ext.should == ".PBS"
    end

    it "should define a file mask of '*.PBS'" do
      AsnFile.file_mask.should == "*.PBS"
    end
  end

  context "when working with remote files" do
    before(:all) do
      @sample_file = "CR20N2730   000000024.0
ORR150352227                    00000039980000000000000000000000000000000000000000001000000000499800000200   000120110812
ODR150352227            C 01703          0373200005037320000500002     00002001ZTESTTRACKCI017030000   SCAC 2              000049900003242         TESTSSLCI01703000001000000040129780373200009
ORR328552614                    00000079960000000000000000000000000000000000000000001000000000899600000500   000120110812
ODR328552614            C 01704          0373200005037320000500002     00002001ZTESTTRACKCI017040000   SCAC 1              000049900003241         TESTSSLCI01704000001000000040129780373200009         "
    end

    before(:each) do
      @client = double('CdfFtpClient')
      CdfFtpClient.stub(:new).and_return(@client)
    end

    context "and there are no ASN files on the server" do
      it "should count 0 files" do
        @client.should_receive(:connect)
        AsnFile.should_receive(:remote_file_path).any_number_of_times.and_return('test')
        AsnFile.remote_files.count.should == 0
      end
    end

    context "and there is 1 ASN files on the server" do
      before(:each) do

        @outgoing_files = [
            "drw-rw-rw-   1 user     group           0 Aug  3 21:52 ..",
            "drw-rw-rw-   1 user     group           0 Aug  3 21:52 .",
            "-rw-rw-rw-   1 user     group         128 Aug  3 13:30 05503677.PBS",
            "-rw-rw-rw-   1 user     group         128 Aug  3 13:30 05503670.pbs",
            "-rw-rw-rw-   1 user     group        1872 Aug  3 20:30 05503658.pbs"
        ]

        @ftp = double('ftp-server')
        @ftp.stub(:chdir).with('outgoing').and_return(nil)
        @ftp.stub(:list).with(AsnFile.file_mask).and_return(@outgoing_files)
        @ftp.stub(:delete).and_return(nil)
        @client.stub(:connect).and_yield(@ftp)
      end

      it "should count only the files ending with .PBS" do
        AsnFile.remote_files.size.should == 1
      end

      context "file is downloaded" do
        before(:each) do
          @file_name = '05503677.PBS'
          asn_file = AsnFile.create_path(@file_name)
          @ftp.should_receive(:gettextfile).any_number_of_times.with(@file_name, asn_file).and_return do
            file = File.new(asn_file, 'w')
            file.write @sample_file
            file.close
            nil
          end
        end
        it "should download the file, create an AsnFile record, and delete the file from the server" do
          AsnFile.needs_import.count.should == 0
          downloaded = AsnFile.download
          downloaded.size.should == 1

          AsnFile.needs_import.count.should == 1
          AsnFile.needs_import.first.should == downloaded.first
          AsnFile.needs_import.first.file_name.should == @file_name
        end

        it "should have 200 chars in each line" do
          AsnFile.download.size.should == 1
          AsnFile.needs_import.first.data.split(/\n/).each do |line|
            line.chomp.length.should == 200
          end
        end

        context "and a Asn file with the same name has already been downloaded" do
          before(:each) do
            AsnFile.download
          end

          it "should make the existing AsnFile old version the new file" do
            orig_asn_file = AsnFile.find_by_file_name @file_name
            orig_asn_file.versions.should == []
            orig_asn_file.parent.should == nil

            AsnFile.download

            orig_asn_file.reload
            orig_asn_file.parent.should_not == nil
            orig_asn_file.versions.should == []

            AsnFile.count.should == 2

            AsnFile.where(:file_name => @file_name).count.should == 1
            AsnFile.where(:file_name => @file_name).count.should == 1
            asn_file = AsnFile.find_by_file_name @file_name
            asn_file.versions.count.should == 1
          end
        end

      end

    end


  end
end