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
      @po_file_name = '110809180859.fbo'
      @po_file = PoFile.create(:file_name => @po_file_name)
      @sample_file = '02000011697978     INGRAM       110809RUNQX110809180859.FBO F030000000     1    1100002             R364143388            20N273016979780110809110809110809     2100003R364143388            THANK YOU FOR YOUR ORDER.  IF YOU REQUIRE ASSISTAN 2100004R364143388            CE, PLEASE CONTACT OURELECTRONIC ORDERING DEPARTME 2100005R364143388            NT AT 1-800-234-6737 OR VIA EMAIL AT        FLASHB 2100006R364143388            ACK@INGRAMBOOK.COM.  TO CANCEL AN ORDER, PLEASE SP 2100007R364143388            EAK WITH AN     ELECTRONIC ORDERING REPRESENTATIVE 2100008R364143388             AT 1-800-234-6737.                                4000009R364143388            1                     9780373200009       00100100C4100010R364143388            000 000000{ 0000 0000 0000 0000 0000 0000 0000     4200011R364143388            HQPB FAMOUS FIRSTS MATCHMAKERSMACOMBER DEBBIE     M4300012R364143388            HQPB                030900019350000000010000000    4400013R364143388                                00004.99EN00003.240000001      4500014R364143388            1                                                  5900015R364143388            0001300000000010000000001000000000400000000000000019100016000000000000100001000000000100001000010002300000000060000100001          '
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
            "-rw-rw-rw-   1 user     group         128 Aug  3 13:30 110809180859.fbc",
            "-rw-rw-rw-   1 user     group        1872 Aug  3 20:30 110809180859.fbo"
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
          @file_name = '110809180859.fbc'
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

            before(:each) do
              @po_file_name = @file_name.gsub(/fbc$/, 'fbo')

              PoFile.should_receive(:find_by_file_name!).any_number_of_times.with(@po_file_name).and_return(@po_file)
              Order.should_receive(:find_by_number!).any_number_of_times.and_return(Order.create)
              @product = Product.new
              @product.sku = '978-0-37320-000-9'
              @product.price = 10
              @product.name = "test product"
              @product.save!
              @variant = @product.master

              @line_item = LineItem.new
              @line_item.variant = @variant
              @line_item.price = 10
              @line_item.should_receive(:order).any_number_of_times.and_return(Order.create)
              @line_item.save!

              PoaFile.download
              PoaFile.needs_import.count.should > 0
              @poa_file = PoaFile.needs_import.first
            end

            it "should import files one by one" do

              @poa_file.import.should_not == nil
              @poa_file.imported_at.should_not == nil

              PoaFile.needs_import.count.should == 0
            end


            it "should import all files" do
              imported = PoaFile.import_all
              imported.size.should == 1
              PoaFile.all.count.should == 1
              PoaFile.first.po_file.should_not == nil
              PoaFile.needs_import.count.should == 0
            end

            context "and the import data is complete" do

              before(:each) do
                @parsed = @poa_file.parsed
                @poa_file.import
              end

              it "should import the PoaFile data" do
                header = @parsed[:header]
                header.should_not == nil
                header.size.should == 1
                header = header.first

                @poa_file.created_at.should_not == nil
                @poa_file.destination_san.should_not == nil

                [:electronic_control_unit,
                 :destination_san,
                 :file_source_name,
                 :format_version,
                 :record_code,
                 :sequence_number
                ].each { |field| should_match_text(@poa_file, header, field) }

                should_match_date(@poa_file, header, :poa_creation_date)

                @poa_file.file_name.should == @file_name
                @poa_file.parent.should == nil
                @poa_file.versions.should == []
                @poa_file.po_file.should == PoFile.find_by_file_name!(@po_file_name)
              end

              #parsed[:poa_vendor_record].should_not == nil
              #parsed[:poa_line_item].should_not == nil
              #parsed[:poa_additional_detail].should_not == nil
              #parsed[:poa_line_item_title_record].should_not == nil
              #parsed[:poa_line_item_pub_record].should_not == nil
              #parsed[:poa_item_number_price_record].should_not == nil
              #parsed[:poa_order_control_total].should_not == nil
              #parsed[:poa_file_control_total].should_not == nil

              it "should import the PoaOrderHeader" do
                r = @parsed[:poa_order_header]
                r.should_not == nil
                r.size.should == 1
                r = r.first

                @poa_file.poa_order_headers.count.should == 1
                poa_order_header = @poa_file.poa_order_headers.first
                poa_order_header.poa_file.should == @poa_file

                poa_order_header.po_status.should == PoStatus.find_by_code('0')

                [:icg_san,
                 :icg_ship_to_account_number,
                 :po_number,
                 :record_code,
                 :sequence_number,
                 :toc
                ].each { |k| should_match_text(poa_order_header, r, k) }

                [:acknowledgement_date, :po_cancellation_date].each { |k| should_match_date(poa_order_header, r, k) }
              end

              it "should import the PoaVendorRecord" do
                vendor_records = @parsed[:poa_vendor_record]
                vendor_records.should_not == nil
                vendor_records.size.should == 6
                header = @poa_file.poa_order_headers.first
                header.poa_vendor_records.count.should == vendor_records.size
                header.vendor_message.should == 'THANK YOU FOR YOUR ORDER. IF YOU REQUIRE ASSISTANCE, PLEASE CONTACT OURELECTRONIC ORDERING DEPARTMENT AT 1-800-234-6737 OR VIA EMAIL AT FLASHBACK@INGRAMBOOK.COM. TO CANCEL AN ORDER, PLEASE SPEAK WITH AN ELECTRONIC ORDERING REPRESENTATIVEAT 1-800-234-6737.'
                header.poa_vendor_records.each_with_index do |record, i|
                  [:po_number,
                   :record_code,
                   :sequence_number,
                   :vendor_message
                  ].each { |k| should_match_text(record, vendor_records[i], k) }
                end
              end

              # todo: need to determine behavior for when this value is altered by ingram
              it "should not have any PoaShipToName" do
                @parsed[:poa_ship_to_name].should == nil
                @poa_file.poa_order_headers.first.poa_ship_to_name.should == nil
              end

              # todo: need to determine behavior for when this value is altered by ingram
              it "should not have any PoaAddressLines" do
                @parsed[:poa_address_lines].should == nil
                @poa_file.poa_order_headers.first.poa_address_lines.should == []
              end

              # todo: need to determine behavior for when this value is altered by ingram
              it "should not have any PoaCityStateZip" do
                @parsed[:poa_city_state_zip].should == nil
                @poa_file.poa_order_headers.first.poa_city_state_zip.should == nil
              end

              it "should import the PoaLineItems" do
                parsed_line_items = @parsed[:poa_line_item]
                #puts parsed_line_items.to_yaml

                @poa_file.poa_order_headers.first.poa_line_items.each_with_index do |poa_line_item, i|
                  parsed = parsed_line_items[i]
                  [:po_number,
                   :record_code,
                   :sequence_number].each { |k| should_match_text(poa_line_item, parsed, k) }

                  parsed[:dc_code].should_not == nil
                  parsed[:dc_code].should == poa_line_item.dc_code.poa_dc_code
                  parsed[:poa_status].should_not == nil
                  parsed[:poa_status].should == poa_line_item.poa_status.code

                  poa_line_item.line_item.should_not == nil
                  poa_line_item.variant.should_not == nil
                  parsed[:line_item_item_number].strip.should == poa_line_item.variant.sku.gsub(/\-/, '')

                  poa_line_item.order.should_not == nil

                end
              end


            end

          end
        end
      end

    end

  end
end


def should_match_text(object, record, field)
  object.send(field).should == record[field].strip
end

def should_match_date(object, record, field, fmt="%y%m%d")
  object.send(field).strftime(fmt).should == Time.strptime(record[field], fmt).strftime(fmt)
end