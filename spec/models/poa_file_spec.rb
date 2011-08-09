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
      @sample_file = '02000011697978     INGRAM       110808RTYOKHB-110808183530.FF030000000     1    1100002             R564547442            20N273016979780110808110808110808     2100003R564547442            THANK YOU FOR YOUR ORDER.  IF YOU REQUIRE ASSISTAN 2100004R564547442            CE, PLEASE CONTACT OURELECTRONIC ORDERING DEPARTME 2100005R564547442            NT AT 1-800-234-6737 OR VIA EMAIL AT        FLASHB 2100006R564547442            ACK@INGRAMBOOK.COM.  TO CANCEL AN ORDER, PLEASE SP 2100007R564547442            EAK WITH AN     ELECTRONIC ORDERING REPRESENTATIVE 2100008R564547442             AT 1-800-234-6737.                                4000009R564547442            219                   9780373200009       00100100C4100010R564547442            000 000000{ 0000 0000 0000 0000 0000 0000 0000     4200011R564547442            HQPB FAMOUS FIRSTS MATCHMAKERSMACOMBER DEBBIE     M4300012R564547442            HQPB                030900019350000000010000000    4400013R564547442                                00004.99EN00003.240000001      4500014R564547442            219                                                5900015R564547442            0001300000000010000000001000000000400000000000000011100016             R327755781            20N273016979780110808110808110808     2100017R327755781            THANK YOU FOR YOUR ORDER.  IF YOU REQUIRE ASSISTAN 2100018R327755781            CE, PLEASE CONTACT OURELECTRONIC ORDERING DEPARTME 2100019R327755781            NT AT 1-800-234-6737 OR VIA EMAIL AT        FLASHB 2100020R327755781            ACK@INGRAMBOOK.COM.  TO CANCEL AN ORDER, PLEASE SP 2100021R327755781            EAK WITH AN     ELECTRONIC ORDERING REPRESENTATIVE 2100022R327755781             AT 1-800-234-6737.                                4000023R327755781            220                   9780373200009       00100100C4100024R327755781            000 000000{ 0000 0000 0000 0000 0000 0000 0000     4200025R327755781            HQPB FAMOUS FIRSTS MATCHMAKERSMACOMBER DEBBIE     M4300026R327755781            HQPB                030900040350000000010000000    4400027R327755781                                00004.99EN00003.240000001      4500028R327755781            220                                                5900029R327755781            0001300000000010000000001000000000400000000000000019100030000000000000200002000000000200001000020001200000000120000200001          '
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
          @ftp.should_receive(:gettextfile).any_number_of_times.with(@file_name, poa_file).and_return do
            file = File.new(poa_file, 'w')
            file.write @sample_file
            file.close
            nil
          end
        end


        it "should download the file, create a PaoFile record, and delete the file from the server" do

          PoaFile.needs_import.count.should == 0
          downloaded = PoaFile.download
          downloaded.size.should == 1
          downloaded.first.versions.size.should == 0

          PoaFile.needs_import.count.should == 1

          PoaFile.needs_import.first.should == downloaded.first

          PoaFile.needs_import.first.file_name.should == @file_name
        end


        it "should have 80 chars in each line" do
          PoaFile.download.size.should == 1
          PoaFile.needs_import.first.data.split(/\n/).each do |line|
            line.chomp.length.should == 80
          end
        end

        context "and a POA file with the same name has already been downloaded" do
          before(:each) do
            PoaFile.download
          end

          it "should make the existing PoaFile old version the new file" do

            orig_poa_file = PoaFile.find_by_file_name @file_name
            orig_poa_file.versions.should == []
            orig_poa_file.parent.should == nil

            PoaFile.download

            orig_poa_file.reload
            orig_poa_file.parent.should_not == nil
            orig_poa_file.versions.should == []

            PoaFile.count.should == 2

            PoaFile.where(:file_name => @file_name).count.should == 1
            PoaFile.where(:file_name => @file_name).count.should == 1
            poa_file = PoaFile.find_by_file_name @file_name
            poa_file.versions.count.should == 1
          end
        end

        context "and the file is imported" do

          context "and there are no POA files to import" do
            it "should have no files that need import" do
              PoaFile.needs_import.count.should == 0
            end
          end

          context "and there are POA files to import" do
            it "should have import files one by one" do
              PoaFile.download
              PoaFile.needs_import.count.should > 0

              Order.should_receive(:find_by_number).any_number_of_times.and_return(Order.create())

              PoaFile.needs_import.each do |p|
                parsed = p.parsed
                parsed[:header].should_not == nil
                parsed[:poa_order_header].should_not == nil
                parsed[:poa_vendor_record].should_not == nil
                parsed[:poa_line_item].should_not == nil
                parsed[:poa_additional_detail].should_not == nil
                parsed[:poa_line_item_title_record].should_not == nil
                parsed[:poa_line_item_pub_record].should_not == nil
                parsed[:poa_item_number_price_record].should_not == nil
                parsed[:poa_order_control_total].should_not == nil
                parsed[:poa_file_control_total].should_not == nil
              end

              PoaFile.needs_import.each do |p|
                p.import.should_not == nil
                p.imported_at.should_not == nil
              end

              PoaFile.needs_import.count.should == 0
            end

            it "should import all files" do
              PoaFile.download
              PoaFile.needs_import.count.should > 0

              Order.should_receive(:find_by_number).any_number_of_times.and_return(Order.create())

              PoaFile.import_all

            end
          end
        end
      end

    end

  end
end
