require_relative '../spec_helper'

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

      @file_names = {
          :outgoing => '05503677.PBS',
          :test => 'T5503677.PBS'
      }
            
      outgoing_contents = "CR20N2730   000000024.0                                                                                                                                                                                 
ORR374103387                    00000019990000000000000000000000000000000000000000001000000000299900000100   000120110812                                                                               
ODR374103387            C 01705          0373200005037320000500001     00001001ZTESTTRACKCI017050000   SCAC 1              000049900003241         TESTSSLCI01705000001000000020129780373200009         
ORR674657678                    00000039980000000000000000000000000000000000000000001000000000499800000200   000120110812                                                                               
ODR674657678            C 01706          0373200005037320000500001     00001001ZTESTTRACKCI017060000   SCAC 2              000049900003242         TESTSSLCI01706000001000000020129780373200009         
"
      test_contents = "CR20N2730   000000024.0                                                                                                                                                                                 
ORR374103387                    00000019990000000000000000000000000000000000000000001000000000299900000100   000120110812                                                                               
ODR374103387            C 01705          0373200005037320000500001     00001001ZTESTTRACKCI017050000   SCAC 1              000049900003241         TESTSSLCI01705000001000000020129780373200009         
ORR674657678                    00000039980000000000000000000000000000000000000000001000000000499800000200   000120110812                                                                               
ODR674657678            C 01706          0373200005037320000500001     00001001ZTESTTRACKCI017060000   SCAC 2              000049900003242         TESTSSLCI01706000001000000020129780373200009         
"
      @sample_file = {
          :outgoing => outgoing_contents,
          :test => test_contents
      }

      @remote_dir = {
          :outgoing => ["-rw-rw-rw-   1 user     group         128 Aug  3 13:30 #{@file_names[:outgoing]}"],
          :test => ["-rw-rw-rw-   1 user     group         128 Aug  3 13:30 #{@file_names[:test]}"]
      }


    end

    before(:each) do
      @client = double('CdfFtpClient')
      CdfFtpClient.should_receive(:new).any_number_of_times.and_return(@client)
    end

    context "and there are no ASN files on the server" do
      it "should count 0 files" do
        @client.should_receive(:dir).with('~/outgoing', '.*\#{@ext}').any_number_of_times.and_return([])
        AsnFile.remote_files.count.should == 0
      end
    end

    context "and there is 1 ASN files on the server" do
      before(:each) do

        ['test', 'outgoing'].each do |dir|
          @client.should_receive(:delete).with("~/#{dir}/#{@file_names[dir.to_sym]}").any_number_of_times.and_return(nil)
          @client.should_receive(:dir).with("~/#{dir}", ".*\\\#{@ext}").any_number_of_times.and_return(@remote_dir[dir.to_sym])
          @client.should_receive(:name_from_path).with(@remote_dir[dir.to_sym].first).any_number_of_times.and_return(@file_names[dir.to_sym])
          @client.should_receive(:get).with("~/#{dir}/#{@file_names[dir.to_sym]}", PoaFile.create_path(@file_names[dir.to_sym])).any_number_of_times.and_return do
            file = File.new(PoaFile.create_path(@file_names[dir.to_sym]), 'w')
            file.write @sample_file[dir.to_sym]
            file.close
            nil
          end
        end

      end

      it "should count only the files ending with .PBS" do
        AsnFile.remote_files.size.should == 1
      end

      context "and the ASN File is downloaded" do
        before(:each) do
          @downloaded = AsnFile.download
          @asn_file = AsnFile.find_by_file_name @file_names[:outgoing]
        end

        after(:each) do
          AsnFile.all.each { |file| file.destroy }
        end

        it "should have the right data" do
          @asn_file.data.should == @sample_file[:outgoing]
        end

        it "should have 0 versions" do
          @asn_file.versions.count.should == 0
        end

        it "should create a new version when downloading a second time" do
          AsnFile.needs_import.count.should == 2
          @downloaded.size.should == 2
          @downloaded.first.versions.size.should == 0

          AsnFile.needs_import.count.should == 2
          AsnFile.needs_import.first.should == @downloaded.first
          downloaded = AsnFile.download
          new_asn_file = AsnFile.find_by_file_name @file_names[:outgoing]
          new_asn_file.versions.count == 1
          new_asn_file.versions.first.file_name.should == @file_names[:outgoing] + ".1"
        end

        it "should have 200 chars in each line" do
          @asn_file.data.split(/\n/).each do |line|
            line.length.should == 200
          end
        end

      end

      context "and a Asn file with the same name has already been downloaded" do

        before(:each) do
          AsnFile.download
          @orig_asn_file = AsnFile.find_by_file_name @file_names[:outgoing]
        end

        it "should make the existing AsnFile old version the new file" do
          @orig_asn_file.versions.should == []
          @orig_asn_file.parent.should == nil

          AsnFile.download

          @orig_asn_file.reload
          @orig_asn_file.parent.should_not == nil
          @orig_asn_file.versions.should == []

          AsnFile.count.should == 4

          AsnFile.where(:file_name => @file_names[:outgoing]).count.should == 1
          asn_file = AsnFile.find_by_file_name @file_names[:outgoing]
          asn_file.versions.count.should == 1
        end
      end

      context "and the file is imported" do

        context "and there are no ASN files to import" do
          it "should have no files that need import" do
            AsnFile.needs_import.count.should == 0
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

            AsnFile.download
            AsnFile.needs_import.count.should > 0
            @asn_file = AsnFile.needs_import.first
            @parsed = @asn_file.parsed
          end

          it "should import files one by one" do
            @asn_file.import.should_not == nil
            @asn_file.imported_at.should_not == nil
            AsnFile.needs_import.count.should == 1
          end

          it "should import all files" do
            imported = AsnFile.import_all
            imported.size.should == 2
            AsnFile.all.count.should == 2
            AsnFile.needs_import.count.should == 0
          end

          context "and asn file is imported" do
            before(:each) do
              @asn_file.import
            end
            it "should return the correct data" do
              @asn_file.data.should == AsnFile.add_delimiters(@sample_file[:outgoing])
            end

            it "should import the AsnFile data" do
              should_import_asn_file_data(@parsed, @asn_file, @file_names[:outgoing])
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
     :quantity_shipped].each { |field| ImportFileHelper.should_match_i(db_record, record, field) }

    db_record.weight.should == BigDecimal.new((record[:weight].to_f / 100).to_s, 0)

    db_record.asn_shipping_method_code.should == AsnShippingMethodCode.find_by_code(record[:shipping_method_or_slash_reason_code])

    db_record.asn_order_status.code.should == record[:item_detail_status_code]

    db_record.dc_code.should_not == nil
    first = record[:shipping_warehouse_code].match(/./).to_s
    codes = DcCode.where("asn_dc_code LIKE ?", "#{first}%")
    db_record.dc_code.should == codes.first

    DcCode.find_by_asn_dc_code(record[:shipping_warehouse_code]).to_yaml

    db_record.line_item = LineItem.find_by_id(record[:line_item_id_number])
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
