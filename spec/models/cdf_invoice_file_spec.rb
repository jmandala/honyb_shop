require "spec_helper"

describe CdfInvoiceFile do

  before(:all) do
    CdfInvoiceFile.all.each &:destroy
  end

  after(:all) do
    CdfInvoiceFile.all.each &:destroy
  end

  context "when defining an CdfInvoiceFiled" do
    it "should specify a record length of 80" do
      CdfInvoiceFile.record_length.should == 80
    end

    it "should specify an extension of 'BIN'" do
      CdfInvoiceFile.ext.should == ".BIN"
    end

    it "should define a file mask of '*.BIN'" do
      CdfInvoiceFile.file_mask.should == "*.BIN"
    end
  end

  context "when working with remote files" do
    before(:all) do
      @sample_file = "0100001169797800000INGRAM BK CO 110822INVOICE COMMUNICATIONS
150000210003868                   20N2730     254410500020110822
450000310003868                   0373200005 000010000499 0035 0000032420110822
460000410003868                                              9780373200009
48000051000386820110822HQPB FAMOUS FIRS00000R483688864            43        0000
4900006100038681ZTESTTRACKCI018370000   0000032400000000000000000000000000000324
450000710003868                   0373200005 000010000499 0035 0000032420110822
460000810003868                                              9780373200009
48000091000386820110822HQPB FAMOUS FIRS00000R746668282            41        0000
4900010100038681ZTESTTRACKCI018360000   0000032400000000000000000000000000000324
550001110003868     0000900002000002TESTCI0001       0000000
570001210003868     000000648      00000000000000000000000000          000000648
150000110003869                   20N2730            00020110822
450000210003869                   555887564X 000010000000 0000 0000000020110822
460000310003869                                              9785558875645
48000041000386920110822 ORDER CHARGE   00000R483688864            43        0000
450000510003869                   5558875666 000010000065 0000 0000006520110822
460000610003869                                              9785558875669
48000071000386920110822 PER PIECE CHARG00000R483688864            43        0000
4900008100038691ZTESTTRACKCI018370000   0000000000000100000650000000000000000066
450000910003869                   555887564X 000010000000 0000 0000000020110822
460001010003869                                              9785558875645
48000111000386920110822 ORDER CHARGE   00000R746668282            41        0000
450001210003869                   5558875666 000010000065 0000 0000006520110822
460001310003869                                              9785558875669
48000141000386920110822 PER PIECE CHARG00000R746668282            41        0000
4900015100038691ZTESTTRACKCI018370000   0000000000000200000650000000000000000067
550001610003869     0001500004000004TESTCI0001       0000000
570001710003869     000000000      00000030000130000000000000          000000133
95000180000000000006000020000000006
"
    end

    before(:each) do
      @client = double('CdfFtpClient')
      CdfFtpClient.stub(:new).and_return(@client)
    end

    context "and there are no ASN files on the server" do
      it "should count 0 files" do
        @client.should_receive(:connect)
        CdfInvoiceFile.should_receive(:remote_file_path).any_number_of_times.and_return('test')
        CdfInvoiceFile.remote_files.count.should == 0
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
        @ftp.stub(:list).with(CdfInvoiceFile.file_mask).and_return(@outgoing_files)
        @ftp.stub(:delete).and_return(nil)
        @client.stub(:connect).and_yield(@ftp)
      end

      it "should count only the files ending with .PBS" do
        CdfInvoiceFile.remote_files.size.should == 1
      end

      context "file is downloaded" do
        before(:each) do
          @file_name = '05503677.PBS'
          asn_file = CdfInvoiceFile.create_path(@file_name)
          @ftp.should_receive(:gettextfile).any_number_of_times.with(@file_name, asn_file).and_return do
            file = File.new(asn_file, 'w')
            file.write @sample_file
            file.close
            nil
          end
        end

        it "should have the correct number of records after the download" do
          CdfInvoiceFile.download
          asn_file = CdfInvoiceFile.find_by_file_name @file_name
          asn_file.data.should == @sample_file
        end

        it "should download the file, create an CdfInvoiceFile record, and delete the file from the server" do
          @ftp.should_receive(:delete).once

          CdfInvoiceFile.needs_import.count.should == 0
          downloaded = CdfInvoiceFile.download
          downloaded.size.should == 1
          downloaded.first.versions.size.should == 0

          CdfInvoiceFile.needs_import.count.should == 1
          CdfInvoiceFile.needs_import.first.should == downloaded.first
          CdfInvoiceFile.needs_import.first.file_name.should == @file_name
        end

        it "should have 200 chars in each line" do
          CdfInvoiceFile.download.size.should == 1
          CdfInvoiceFile.needs_import.first.data.split(/\n/).each do |line|
            line.length.should == 200
          end
        end

        context "and a Asn file with the same name has already been downloaded" do
          before(:each) do
            CdfInvoiceFile.download
          end

          it "should make the existing CdfInvoiceFile old version the new file" do
            orig_asn_file = CdfInvoiceFile.find_by_file_name @file_name
            orig_asn_file.versions.should == []
            orig_asn_file.parent.should == nil

            CdfInvoiceFile.download

            orig_asn_file.reload
            orig_asn_file.parent.should_not == nil
            orig_asn_file.versions.should == []

            CdfInvoiceFile.count.should == 2

            CdfInvoiceFile.where(:file_name => @file_name).count.should == 1
            CdfInvoiceFile.where(:file_name => @file_name).count.should == 1
            asn_file = CdfInvoiceFile.find_by_file_name @file_name
            asn_file.versions.count.should == 1
          end
        end

        context "and the file is imported" do

          context "and there are no ASN files to import" do
            it "should have no files that need import" do
              CdfInvoiceFile.needs_import.count.should == 0
            end
          end

          context "and there are ASN files to import" do
            before(:each) do
              @order_1 = FactoryGirl.create(:order, :number => 'R374103387')
              @order_2 = FactoryGirl.create(:order, :number => 'R674657678')

              @product = Factory(:product, :sku => '978-0-37320-000-9', :price => 10, :name => 'test product')
              @variant = @product.master
              @line_item = Factory(:line_item, :variant => @variant, :price => 10, :order => @order_1)
              LineItem.should_receive(:find_by_id!).any_number_of_times.with("1").and_return(@line_item)

              CdfInvoiceFile.download
              CdfInvoiceFile.needs_import.count.should > 0
              @asn_file = CdfInvoiceFile.needs_import.first
              @parsed = @asn_file.parsed
            end

            it "should import files one by one" do
              @asn_file.import.should_not == nil
              @asn_file.imported_at.should_not == nil
              CdfInvoiceFile.needs_import.count.should == 0
            end

            it "should import all files" do
              imported = CdfInvoiceFile.import_all
              imported.size.should == 1
              CdfInvoiceFile.all.count.should == 1
              CdfInvoiceFile.needs_import.count.should == 0
            end

            context "and asn file is imported" do
              before(:each) do
                @asn_file.import
              end
              it "should return the correct data" do
                @asn_file.data.should == CdfInvoiceFile.add_delimiters(@sample_file)
              end

              it "should import the CdfInvoiceFile data" do
                should_import_asn_file_data(@parsed, @asn_file, @file_name)
              end

              it "should import the ASN Shipment record" do
                should_import_asn_shipment_record(@parsed, @asn_file)
              end
              it "should import the ASN Shipment Detail record" do
                should_import_asn_shipment_detail_record(@parsed, @asn_file)
              end
            end

          end
        end

      end

    end

  end
end

def should_import_asn_shipment_detail_record(parsed, asn_file)
  parsed[:asn_shipment_detail].each do |record|
    db_record = AsnShipmentDetail.find_self asn_file, record[:client_order_id]
    db_record.should_not == nil
    db_record.asn_file.should == asn_file
    db_record.order.should_not == nil
    db_record.record_code.should == 'OD'
    db_record.order.should == Order.find_by_number(record[:client_order_id].strip)

    [:ingram_order_entry_number,
     :isbn_10_ordered,
     :isbn_10_shipped,
     :tracking_number,
     :standard_carrier_address_code,
     :ssl,
     :isbn_13].each { |field| ImportFileHelper.should_match_text(db_record, record, field) }

    [:ingram_item_list_price,
     :net_discounted_price].each { |field| ImportFileHelper.should_match_money(db_record, record, field) }

    [:quantity_canceled,
    :quantity_predicted,
    :quantity_slashed,
    :quantity_shipped].each {|field| ImportFileHelper.should_match_i(db_record, record, field)}
    
    db_record.weight.should == BigDecimal.new((record[:weight].to_f / 100).to_s, 0)

    db_record.asn_shipping_method_code.should == AsnShippingMethodCode.find_by_code(record[:shipping_method_or_slash_reason_code])

    db_record.asn_order_status.code.should == record[:item_detail_status_code]

    db_record.dc_code.should_not == nil
    first = record[:shipping_warehouse_code].match(/./).to_s
    codes = DcCode.where("asn_dc_code LIKE ?", "#{first}%")
    db_record.dc_code.should == codes.first

    DcCode.find_by_asn_dc_code(record[:shipping_warehouse_code]).to_yaml

    db_record.line_item = LineItem.find_by_id(record[:line_item_id_number])
    puts db_record.line_item.to_yaml

  end
end

def should_import_asn_shipment_record(parsed, asn_file)
  parsed[:asn_shipment].each do |record|
    db_record = AsnShipment.find_self asn_file, record[:client_order_id]
    db_record.should_not == nil
    db_record.asn_file.should == asn_file
    db_record.order.should_not == nil
    db_record.record_code.should == 'OR'
    db_record.order.should == Order.find_by_number(record[:client_order_id].strip)
    db_record.asn_order_status.code.should == record[:order_status_code]

    [:consumer_po_number].each { |field| ImportFileHelper.should_match_text(db_record, record, field) }

    [:order_subtotal,
     :order_discount_amount,
     :order_total,
     :freight_charge].each { |field| ImportFileHelper.should_match_money(db_record, record, field) }

    db_record.shipping_and_handling.should == BigDecimal.new((record[:shipping_and_handling].to_f / 10000).to_s, 0)
  end
end

def should_import_asn_file_data(parsed, asn_file, file_name)
  all = parsed[:header]
  all.should_not == nil
  all.size.should == 1
  parsed = all.first

  db_record = asn_file
  db_record.record_code.should == 'CR'
  db_record.created_at.should_not == nil

  [:company_account_id_number, :file_version_number, :record_code].each do |field|
    ImportFileHelper.should_match_text(db_record, parsed, field)
  end

  [:total_order_count].each { |field| ImportFileHelper.should_match_i(db_record, parsed, field) }

  db_record.file_version_number.should == '4.0'
  db_record.file_name.should == file_name
  db_record.parent.should == nil
  db_record.versions.should == []
end
