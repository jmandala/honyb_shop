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
      @sample_file = "CR20N2730   000000024.0                                                                                                                                                                                 
ORR374103387                    00000019990000000000000000000000000000000000000000001000000000299900000100   000120110812                                                                               
ODR374103387            C 01705          0373200005037320000500001     00001001ZTESTTRACKCI017050000   SCAC 1              000049900003241         TESTSSLCI01705000001000000020129780373200009         
ORR674657678                    00000039980000000000000000000000000000000000000000001000000000499800000200   000120110812                                                                               
ODR674657678            C 01706          0373200005037320000500001     00001001ZTESTTRACKCI017060000   SCAC 2              000049900003242         TESTSSLCI01706000001000000020129780373200009         
"
      @test_sample_file = "CR20N2730   000000024.0                                                                                                                                                                                 
ORR374103387                    00000019990000000000000000000000000000000000000000001000000000299900000100   000120110812                                                                               
ODR374103387            C 01705          0373200005037320000500001     00001001ZTESTTRACKCI017050000   SCAC 1              000049900003241         TESTSSLCI01705000001000000020129780373200009         
ORR674657678                    00000039980000000000000000000000000000000000000000001000000000499800000200   000120110812                                                                               
ODR674657678            C 01706          0373200005037320000500001     00001001ZTESTTRACKCI017060000   SCAC 2              000049900003242         TESTSSLCI01706000001000000020129780373200009         
"
    end

    before(:each) do
      @client = double('CdfFtpClient')
      CdfFtpClient.stub(:new).and_return(@client)
    end

    context "and there are no ASN files on the server" do
      it "should count 0 files" do
        @client.should_receive(:dir).with('~/outgoing', '.*\#{@ext}').and_return([])
        AsnFile.remote_files.count.should == 0
      end
    end

    context "and there is 1 ASN files on the server" do
      before(:each) do

        @outgoing_all = [
            "drw-rw-rw-   1 user     group           0 Aug  3 21:52 ..",
            "drw-rw-rw-   1 user     group           0 Aug  3 21:52 .",
            "-rw-rw-rw-   1 user     group         128 Aug  3 13:30 05503677.PBS",
            "-rw-rw-rw-   1 user     group         128 Aug  3 13:30 05503670.pbs",
            "-rw-rw-rw-   1 user     group        1872 Aug  3 20:30 05503658.pbs"
        ]

        @outgoing_filtered = [
            "-rw-rw-rw-   1 user     group         128 Aug  3 13:30 05503677.PBS",
        ]

        @test_filtered = [
            "-rw-rw-rw-   1 user     group         128 Aug  3 13:30 T5503677.PBS",
        ]

        @test_files = [
            "drw-rw-rw-   1 user     group           0 Aug  3 21:52 ..",
            "drw-rw-rw-   1 user     group           0 Aug  3 21:52 .",
            "-rw-rw-rw-   1 user     group         128 Aug  3 13:30 T5503677.PBS",
            "-rw-rw-rw-   1 user     group         128 Aug  3 13:30 T5503670.pbs",
            "-rw-rw-rw-   1 user     group        1872 Aug  3 20:30 T5503658.pbs"
        ]
        
        @file_name = '05503677.PBS'        
        @test_file_name = 'T5503677.PBS'        

        @client.should_receive(:delete).any_number_of_times.and_return(nil)
        @client.should_receive(:dir).with('~/outgoing', '.*\#{@ext}').any_number_of_times.and_return(@outgoing_filtered)
        @client.should_receive(:name_from_path).with("-rw-rw-rw-   1 user     group         128 Aug  3 13:30 05503677.PBS").any_number_of_times.and_return("05503677.PBS")
        @client.should_receive(:get).with("~/outgoing/05503677.PBS", AsnFile.create_path(@file_name)).any_number_of_times.and_return do
          file = File.new(AsnFile.create_path(@file_name), 'w')
          file.write @sample_file
          file.close
          nil
        end


        @client.should_receive(:dir).with('~/test', '.*\#{@ext}').any_number_of_times.and_return(@test_filtered)
        @client.should_receive(:name_from_path).with("-rw-rw-rw-   1 user     group         128 Aug  3 13:30 T5503677.PBS").any_number_of_times.and_return("T5503677.PBS")
        @client.should_receive(:get).with("~/test/#{@test_file_name}", AsnFile.create_path(@test_file_name)).any_number_of_times.and_return do
          file = File.new(AsnFile.create_path(@test_file_name), 'w')
          file.write @test_sample_file
          file.close
          nil
        end

        @client.should_receive(:delete).with("~/outgoing/#{@file_name}").any_number_of_times.and_return(nil)
        @client.should_receive(:delete).with("~/test/#{@test_file_name}").any_number_of_times.and_return(nil)
      end

      it "should count only the files ending with .PBS" do
        AsnFile.remote_files.size.should == 1
      end

      context "and the ASN File is downloaded" do
        before(:each) do
          @downloaded = AsnFile.download
          @asn_file = AsnFile.find_by_file_name @file_name
        end

        after(:each) do
          AsnFile.all.each { |file| file.destroy }
        end

        it "should have the right data" do
          @asn_file.data.should == @sample_file
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
          new_asn_file = AsnFile.find_by_file_name @file_name
          new_asn_file.versions.count == 1
          new_asn_file.versions.first.file_name.should == @file_name + ".1"
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
          @orig_asn_file =  AsnFile.find_by_file_name @file_name
        end
        
        it "should make the existing AsnFile old version the new file" do
          @orig_asn_file.versions.should == []
          @orig_asn_file.parent.should == nil

          AsnFile.download

          @orig_asn_file.reload
          @orig_asn_file.parent.should_not == nil
          @orig_asn_file.versions.should == []

          AsnFile.count.should == 4

          AsnFile.where(:file_name => @file_name).count.should == 1
          asn_file = AsnFile.find_by_file_name @file_name
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
              @asn_file.data.should == AsnFile.add_delimiters(@sample_file)
            end

            it "should import the AsnFile data" do
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
