require 'spec_helper'

MAX_POA_VENDOR_RECORDS = 6

describe PoaFile do

  before(:all) do
    PoaFile.all.each &:destroy
    LineItem.all.each &:destroy
    Order.all.each &:destroy
  end

  after(:all) do
    PoaFile.all.each &:destroy
    LineItem.all.each &:destroy
    Order.all.each &:destroy
  end

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

      context "when importing an exception file" do
        before(:each) do
          @file_name = '110809180859.fbc'
          poa_file = PoaFile.create_path(@file_name)
          @ftp.should_receive(:gettextfile).any_number_of_times.with(@file_name, poa_file).and_return do
            file = File.new(poa_file, 'w')
            file.write 'NO MAINFRAME'
            file.close
            nil
          end

          @po_file_name = @file_name.gsub(/fbc$/, 'fbo')
          PoFile.should_receive(:find_by_file_name!).any_number_of_times.with(@po_file_name).and_return(@po_file)

          @order = Factory(:order, :number => 'R364143388')
          @product = Factory(:product, :sku => '978-0-37320-000-9', :price => 10, :name => 'test product')
          @variant = @product.master
          @line_item = Factory(:line_item, :variant => @variant, :price => 10, :order => @order)
          LineItem.should_receive(:find_by_id!).any_number_of_times.with("1").and_return(@line_item)

          PoaFile.download
          PoaFile.needs_import.count.should > 0
          @poa_file = PoaFile.needs_import.first
        end

        it "should log an error message" do
          result = @poa_file.import
          result.class.should == CdfImportExceptionLog
        end
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

              @order = Factory(:order, :number => 'R364143388')
              @product = Factory(:product, :sku => '978-0-37320-000-9', :price => 10, :name => 'test product')
              @variant = @product.master
              @line_item = Factory(:line_item, :variant => @variant, :price => 10, :order => @order)
              LineItem.should_receive(:find_by_id!).any_number_of_times.with("1").and_return(@line_item)

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

            context "and the po contains 2 orders with 2 line items each with a quantity of 2" do
              before(:each) do

                @product_1 = Factory(:product, :sku => '978-0-37320-000-9', :price => 10, :name => 'test product')
                @product_2 = Factory(:product, :sku => '978-0-37352-80-5', :price => 10, :name => 'test product 2')


                @order_1 = Factory(:order, :number => 'R543255800')

                @line_item_1 = Factory(:line_item, :quantity => 2, :variant => @product_1.master, :price => 10, :order => @order_1)
                LineItem.should_receive(:find_by_id!).any_number_of_times.with("2").and_return(@line_item_1)

                @line_item_2 = Factory(:line_item, :quantity => 2, :variant => @product_2.master, :price => 10, :order => @order_1)
                LineItem.should_receive(:find_by_id!).any_number_of_times.with("5").and_return(@line_item_2)

                @order_2 = Factory(:order, :number => 'R554266337')
                @line_item_3 = Factory(:line_item, :quantity => 2, :variant => @product_1.master, :price => 10, :order => @order_2)
                LineItem.should_receive(:find_by_id!).any_number_of_times.with("3").and_return(@line_item_3)

                @line_item_4 = Factory(:line_item, :quantity => 2, :variant => @product_2.master, :price => 10, :order => @order_2)
                LineItem.should_receive(:find_by_id!).any_number_of_times.with("6").and_return(@line_item_4)


                @poa_with_2_by_2_by_2 = "02000011697978     INGRAM       110810RUYFU110809180859.FBO F030000000     1    1100002             R543255800            20N273016979780110810110810110810     2100003R543255800            THANK YOU FOR YOUR ORDER.  IF YOU REQUIRE ASSISTAN 2100004R543255800            CE, PLEASE CONTACT OURELECTRONIC ORDERING DEPARTME 2100005R543255800            NT AT 1-800-234-6737 OR VIA EMAIL AT        FLASHB 2100006R543255800            ACK@INGRAMBOOK.COM.  TO CANCEL AN ORDER, PLEASE SP 2100007R543255800            EAK WITH AN     ELECTRONIC ORDERING REPRESENTATIVE 2100008R543255800             AT 1-800-234-6737.                                4000009R543255800            2                     9780373200009       00100100C4100010R543255800            000 000000{ 0000 0000 0000 0000 0000 0000 0000     4200011R543255800            HQPB FAMOUS FIRSTS MATCHMAKERSMACOMBER DEBBIE     M4300012R543255800            HQPB                030900019350000000010000000    4400013R543255800                                00004.99EN00003.240000001      4500014R543255800            2                                                  4000015R543255800            5                     978037352805        00100005C4100016R543255800            000         0000 0000 0000 0000 0000 0000 0000     4100017R543255800            000 000000  0000 0000 0000 0000 0000 0000 0000     4200018R543255800                                                               4300019R543255800                                    00022000000000000000000    4400020R543255800                                00000.00EN00000.000000001      4500021R543255800            5                                                  5900022R543255800            0002000000000020000000001000000000400000000000000011100023             R554266337            20N273016979780110810110810110810     2100024R554266337            THANK YOU FOR YOUR ORDER.  IF YOU REQUIRE ASSISTAN 2100025R554266337            CE, PLEASE CONTACT OURELECTRONIC ORDERING DEPARTME 2100026R554266337            NT AT 1-800-234-6737 OR VIA EMAIL AT        FLASHB 2100027R554266337            ACK@INGRAMBOOK.COM.  TO CANCEL AN ORDER, PLEASE SP 2100028R554266337            EAK WITH AN     ELECTRONIC ORDERING REPRESENTATIVE 2100029R554266337             AT 1-800-234-6737.                                4000030R554266337            3                     9780373200009       00100100C4100031R554266337            000 000000{ 0000 0000 0000 0000 0000 0000 0000     4200032R554266337            HQPB FAMOUS FIRSTS MATCHMAKERSMACOMBER DEBBIE     M4300033R554266337            HQPB                030900043350000000010000000    4400034R554266337                                00004.99EN00003.240000001      4500035R554266337            3                                                  4000036R554266337            6                     978037352805        00100005C4100037R554266337            000         0000 0000 0000 0000 0000 0000 0000     4100038R554266337            000 000000  0000 0000 0000 0000 0000 0000 0000     4200039R554266337                                                               4300040R554266337                                    00046000000000000000000    4400041R554266337                                00000.00EN00000.000000001      4500042R554266337            6                                                  5900043R554266337            0002000000000020000000001000000000400000000000000019100044000000000000400002000000000200001000020001200000000260000200001          "
                @poa_file.write_data @poa_with_2_by_2_by_2
                @parsed = @poa_file.parsed

                @poa_file.import
              end

              it "should return the correct data" do
                @poa_file.data.should == PoaFile.add_delimiters(@poa_with_2_by_2_by_2)
              end

              it "should import the PoaFile data" do
                should_import_poa_file_data(@parsed, @poa_file, @file_name, @po_file_name)
              end

              it "should import the PoaOrderHeader" do
                should_import_poa_order_header(@poa_file, @parsed, order_count=2, item_count=2)
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
                should_import_poa_line_items @parsed
              end

              it "should import the PoaAdditionalDetails" do
                should_import_poa_additional_details @poa_file, @parsed
              end

              it "should import the PoaAdditionalLineItemRecord" do
                should_import_poa_line_item_title_record @poa_file, @parsed
              end

              it "should import the PoaLineItemPubRecord" do
                should_import_poa_line_item_pub_record @poa_file, @parsed
              end

              it "should import the PoaItemNumberPriceRecord" do
                parsed = @parsed[:poa_item_number_price_records]
                parsed.should == nil
              end

              it "should import the PoaOrderControlTotal" do
                should_import_poa_order_control_total @poa_file, @parsed
              end

              it "should import the PoaFileControlTotal" do
                should_import_poa_file_control_total @poa_file, @parsed
              end


            end
            context "and the po contains 1 order with 1 line item with 1 quantity" do

              before(:each) do
                @parsed = @poa_file.parsed
                @poa_file.import
              end

              it "should import the PoaFile data" do
                should_import_poa_file_data(@parsed, @poa_file, @file_name, @po_file_name)
              end

              it "should import the PoaOrderHeader" do
                should_import_poa_order_header(@poa_file, @parsed, order_count=1, item_count=1)
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
                should_import_poa_line_items @parsed
              end

              it "should import the PoaAdditionalDetails" do
                should_import_poa_additional_details @poa_file, @parsed
              end

              it "should import the PoaAdditionalLineItemRecord" do
                should_import_poa_line_item_title_record @poa_file, @parsed
              end

              it "should import the PoaLineItemPubRecord" do
                should_import_poa_line_item_pub_record @poa_file, @parsed
              end

              it "should import the PoaItemNumberPriceRecord" do
                parsed = @parsed[:poa_item_number_price_records]
                parsed.should == nil
              end

              it "should import the PoaOrderControlTotal" do
                should_import_poa_order_control_total @poa_file, @parsed
              end

              it "should import the PoaFileControlTotal" do
                should_import_poa_file_control_total @poa_file, @parsed
              end

            end
          end
        end
      end
    end
  end
end


def should_match_text(object, record, field)
  object.read_attribute(field).should == record[field].strip
end

def should_match_i(object, record, field)
  object.send(field).should == record[field].strip.to_i
end

def should_match_date(object, record, field, fmt="%y%m%d")
  import_value = record[field]
  object_value = object.send(field)

  if import_value.to_i == 0
    return object_value.should == nil
  end

  object_value.strftime(fmt).should == Time.strptime(import_value, fmt).strftime(fmt)
end

def should_import_poa_order_header(poa_file, parsed, order_count, item_count)
  all = parsed[:poa_order_header]
  all.should_not == nil
  all.size.should == order_count
  poa_file.poa_order_headers.count.should == order_count

  all.each_with_index do |record, i|
    db_record = poa_file.poa_order_headers[i]
    db_record.poa_file.should == poa_file
    db_record.po_status.code.should == record[:po_status].to_i
    db_record.order.should_not == nil
    db_record.order.number.should_not == nil
    db_record.order.number.should == record[:po_number].strip

    db_record.poa_vendor_records.count.should == MAX_POA_VENDOR_RECORDS
    db_record.poa_ship_to_name.should == nil
    db_record.poa_address_lines.should == []
    db_record.poa_city_state_zip.should == nil
    db_record.poa_line_items.count.should == item_count


    db_record.poa_additional_details.count.should > 0
    db_record.poa_line_item_title_records.count.should == item_count
    db_record.poa_line_item_pub_records.count.should == item_count
    db_record.poa_item_number_price_records.count.should == item_count

    db_record.poa_order_control_total.should_not == nil

    [:icg_san,
     :icg_ship_to_account_number,
     :po_number,
     :record_code,
     :sequence_number,
     :toc
    ].each { |k| should_match_text(db_record, record, k) }

    [:acknowledgement_date, :po_cancellation_date, :po_date].each { |k| should_match_date(db_record, record, k) }
  end
end

def should_import_poa_additional_details(poa_file, parsed)
  parsed[:poa_additional_detail].each do |record|
    db_record = PoaAdditionalDetail.find_self poa_file, record[:sequence_number]
    db_record.should_not == nil

    [:po_number,
     :record_code,
     :sequence_number,
     :dc_inventory_information].each { |k| should_match_text(db_record, record, k) }

    if !record[:availability_date].nil?
      [:availability_date].each { |k| should_match_date(db_record, record, k) }
    end

    db_record.nearest_poa_line_item.should == db_record.poa_line_item
    db_record.poa_line_item.should_not == nil
  end
end

def should_import_poa_line_item_title_record(poa_file, parsed)
  parsed[:poa_line_item_title_record].each do |record|
    db_record = PoaLineItemTitleRecord.find_self poa_file, record[:sequence_number]

    [:title,
     :author,
     :record_code,
     :sequence_number].each { |k| should_match_text(db_record, record, k) }

    record[:binding_code].should == db_record.cdf_binding_code.code
  end
end


def should_import_poa_line_items(parsed)
  parsed[:poa_line_item].each do |record|
    db_record = PoaLineItem.find_by_line_item_po_number(record[:line_item_po_number].strip)
    db_record.should_not == nil

    [:po_number,
     :record_code,
     :sequence_number].each { |k| should_match_text(db_record, record, k) }

    record[:dc_code].should_not == nil
    record[:dc_code].should == db_record.dc_code.poa_dc_code
    record[:poa_status].should_not == nil
    record[:poa_status].should == db_record.poa_status.code
    db_record.order.should_not == nil
    record[:po_number].strip.should == db_record.order.number

    db_record.line_item.should_not == nil
    db_record.variant.should_not == nil

    record[:line_item_item_number].strip.should == db_record.variant.sku.gsub(/\-/, '')
  end
end


def should_import_poa_file_data(parsed, poa_file, file_name, po_file_name)
  all = parsed[:header]
  all.should_not == nil
  all.size.should == 1
  parsed = all.first

  db_record = poa_file
  db_record.created_at.should_not == nil
  db_record.destination_san.should_not == nil

  [:electronic_control_unit,
   :destination_san,
   :file_source_name,
   :format_version,
   :record_code,
   :sequence_number
  ].each { |field| should_match_text(db_record, parsed, field) }

  should_match_date(db_record, parsed, :poa_creation_date)

  db_record.file_name.should == file_name
  db_record.parent.should == nil
  db_record.versions.should == []
  db_record.po_file.should == PoFile.find_by_file_name!(po_file_name)
end

def should_import_poa_file_control_total(poa_file, parsed)
  parsed[:poa_file_control_total].each do |record|

    db_record = PoaFileControlTotal.find_by_poa_file_id(poa_file.id)

    [:record_code, :sequence_number].each { |k| should_match_text(db_record, record, k) }
    [:record_count_01,
     :record_count_02,
     :record_count_03,
     :record_count_04,
     :record_count_05,
     :record_count_06,
     :total_line_items_in_file,
     :total_pos_acknowledged,
     :total_units_acknowledged].each { |k| should_match_i(db_record, record, k) }
  end
end


def should_import_poa_order_control_total(poa_file, parsed)
  @parsed[:poa_order_control_total].each do |record|
    db_record = PoaOrderControlTotal.find_self(@poa_file, record[:sequence_number])

    [:record_code,
     :sequence_number].each { |k| should_match_text(db_record, record, k) }
    [:total_line_items_in_file,
     :total_units_acknowledged,].each { |k| should_match_i(db_record, record, k) }

    db_record.total_line_items_in_file.should == db_record.poa_order_header.poa_line_items.count
  end
end


def should_import_poa_line_item_pub_record(poa_file, parsed)
  @parsed[:poa_line_item_pub_record].each do |record|
    db_record = PoaLineItemPubRecord.find_self(@poa_file, record[:sequence_number])

    [:publisher_name,
     :original_seq_number,
     :total_qty_predicted_to_ship_primary,
     :record_code,
     :sequence_number].each { |k| should_match_text(db_record, record, k) }

    if record[:publication_release_date].empty?
      db_record.publication_release_date.should == nil
    else
      db_record.publication_release_date.strftime("%m%y").should == record[:publication_release_date]
    end
  end
end
