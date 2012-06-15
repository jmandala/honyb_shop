require 'spec_helper'

describe PoFile do

  before :each do
    Cdf::Config.init_from_config unless Cdf::Config.instance    
  end
  
  after :each do 
    Order.all.each &:destroy
  end

  let(:builder) { Cdf::OrderBuilder }
  let(:create_order) { builder.completed_test_order({:id => 5,
                                                     :name => 'single order/multiple lines/multiple quantity: Hawaii',
                                                     :line_item_count => 2,
                                                     :line_item_qty => 2,
                                                     :ship_location => :HI}) }

  let(:generate_po_file) { PoFile.generate }

  it "should create a PO file and submit it after creating an order" do
    Delayed::Worker.delay_jobs = false

    Order.count.should == 0
    order = create_order
    Order.count.should == 1

    id = order.id
    order = Order.find_by_id(id)
    order.payment.state.should == "completed"
    order.needs_po?.should == false
    order.po_file.should_not == nil
    order.po_file.orders.include?(order).should == true

    order.po_file.submitted_at.should_not == nil
    order.po_file.submitted?.should == true
  end

  it "should create an order, and find the order it creates" do
    Order.count.should == 0
    order = create_order
    Order.count.should == 1
    Order.find_by_id(order.id).should == order
  end

  it "should still have no orders!" do
    Order.count.should == 0
  end

  context "default behaviors" do

    before(:each) do
      @po_file = PoFile.new
      @po_file.should_not == nil
    end

    after(:each) do
      @po_file.destroy
    end

    it "should init the counters" do
      @po_file.count[:total_records].should_not == nil
      @po_file.count[:total_purchase_orders].should_not == nil
      @po_file.count[:total_line_items].should_not == nil
      @po_file.count[:total_units].should_not == nil
      (0..8).each { |i| @po_file.count[i.to_s].should_not == nil }
    end

    it "should init the file name after create" do
      @po_file.file_name.should == nil
      @po_file.save
      @po_file.file_name.should_not == nil
      @po_file.file_name.should == PoFile.prefix + @po_file.created_at.strftime("%y%m%d%H%M%S") + PoFile.ext
    end

    it "should do nothing if attempting to delete non-existent file" do
      @po_file.has_file?.should == false
      @po_file.delete_file.should == false
    end

    it "should raise error if path is called" do
      error = nil
      begin
        @po_file.path
      rescue => e
        error = e
      end

      error.should_not == nil
    end

    it "should not have a file yet" do
      @po_file.has_file?.should == false
    end
  end

  context "when generating a purchase order" do

    before :each do
      @order = create_order
      @order.save!

      @po_file = @order.po_file
    end

    after(:all) do
      @po_file.delete_file if @po_file
    end

    it "should have orders" do
      @po_file.orders.should == [@order]
    end

    it "should not have poa_files" do
      @po_file.poa_files.count.should == 0
    end

    it "should be a test purchase order" do
      @po_file.po_type.should == PoFile::PO_TYPE[:test_purchase_order]
    end

    it "should read the purchase order" do
      @po_file.read.should_not == nil
    end

    it "should put the file to the FTP server" do
      @po_file.put.should == @po_file.submitted_at
      @po_file.submitted_at.should_not == nil
      @po_file.submitted?.should == true

      @client = CdfFtpClient.new

      @client.incoming_files.should == []
      @client.archive_files.should == []
      @client.outgoing_files.should == []
      @client.test_files.should == []
    end

    it "should return the previous submitted at data if submitted twice" do
      @po_file.put
      previous = @po_file.submitted_at
      @po_file.put.should == previous
    end


    context "when parsing a PoFile" do

      before :each do
        @parsed = FixedWidth.parse(File.new(@po_file.path), :po_file)
        @po_file.orders.count.should == 1
        @po_file.orders.should == [@order]
      end

      before :all do
        FixedWidth.define :po_file do |d|
          d.template :default do |t|
            t.record_code 2
            t.sequence_number 5
            t.po_number 22
          end

          d.po_00(:align => :left) do |h|
            h.trap { |line| line[0, 2] == '00' }
            h.record_code 2
            h.sequence_number 5
            h.file_source_san 7
            h.spacer 5
            h.files_source_name 13
            h.creation_date 6
            h.file_name 22
            h.format_version 3
            h.ingram_san 7
            h.spacer 5
            h.vendor_name_flag 1
            h.product_description 4
          end

          d.po_10(:align => :left) do |l|
            l.trap { |line| line[0, 2] == '10' }
            l.template :default
            l.ingram_bill_to_account_number 7
            l.vendor_san 7
            l.order_date 6
            l.backorder_cancel_date 6
            l.backorder_code 1
            l.ddc_fulfillment 1
            l.spacer 7
            l.spacer 2
            l.ship_to_indicator 1
            l.bill_to_indicator 1
            l.spacer 6
            l.spacer 1
            l.spacer 5
          end

          d.po_20(:align => :left) do |l|
            l.trap { |line| line[0, 2] == '20' }
            l.template :default
            l.special_handling_codes 30
            l.spacer 21
          end

          d.po_21(:align => :left, :trim => false) do |l|
            l.trap { |line| line[0, 2] == '21' }
            l.template :default
            l.ingram_ship_to_account_number 7
            l.po_type 1
            l.split_shipment_type 2
            l.dc_code 1
            l.spacer 1
            l.green_light 1
            l.spacer 1
            l.poa_type 1
            l.ship_to_password 8
            l.carrier_shipping_method 25
            l.spacer 1
            l.split_order_allowed 1
            l.spacer 1
          end


          d.po_24(:align => :left, :trim => false) do |l|
            l.trap { |line| line[0, 2] == '24' }
            l.template :default
            l.sales_tax_percent 8
            l.freight_tax_percent 7
            l.freight_amount 8
            l.spacer 28
          end

          d.po_25(:align => :left, :trim => false) do |l|
            l.trap { |line| line[0, 2] == '25' }
            l.template :default
            l.purchasing_consumer_name 35
            l.spacer 16
          end

          d.po_26(:align => :left, :trim => false) do |l|
            l.trap { |line| line[0, 2] == '26' }
            l.template :default
            l.purchaser_phone_number 25
            l.spacer 26
          end

          d.po_27(:align => :left, :trim => false) do |l|
            l.trap { |line| line[0, 2] == '27' }
            l.template :default
            l.purchase_address_line 35
            l.spacer 16
          end

          d.po_29(:align => :left, :trim => false) do |l|
            l.trap { |line| line[0, 2] == '29' }
            l.template :default
            l.purchaser_city 25
            l.purchaser_state 3
            l.purchaser_postal_code 11
            l.purchaser_country 3
            l.spacer 9
          end

          d.po_30(:align => :left, :trim => false) do |l|
            l.trap { |line| line[0, 2] == '30' }
            l.template :default
            l.recipient_consumer_name 35
            l.spacer 15
            l.address_validation 1
          end

          d.po_31(:align => :left, :trim => false) do |l|
            l.trap { |line| line[0, 2] == '31' }
            l.template :default
            l.recipient_phone 25
            l.spacer 26
          end

          d.po_32(:align => :left, :trim => false) do |l|
            l.trap { |line| line[0, 2] == '32' }
            l.template :default
            l.recipient_address_line 35
            l.spacer 16
          end

          d.po_34(:align => :left, :trim => false) do |l|
            l.trap { |line| line[0, 2] == '34' }
            l.template :default
            l.recipient_city 25
            l.recipient_state 3
            l.recipient_postal_code 11
            l.recipient_country 3
            l.spacer 9
          end

          d.po_35(:align => :left, :trim => false) do |l|
            l.trap { |line| line[0, 2] == '35' }
            l.template :default
            l.spacer 8
            l.gift_wrap_fee 7
            l.send_consumer_email 1
            l.order_level_gift_indicator 1
            l.suppress_price_indicator 1
            l.order_level_gift_wrap_code 3
            l.spacer 30
          end

          d.po_36(:align => :left, :trim => false) do |l|
            l.trap { |line| line[0, 2] == '36' }
            l.template :default
            l.special_delivery_instructions 51
          end

          d.po_37(:align => :left, :trim => false) do |l|
            l.trap { |line| line[0, 2] == '37' }
            l.template :default
            l.marketing_message 51
          end

          d.po_38(:align => :left, :trim => false) do |l|
            l.trap { |line| line[0, 2] == '38' }
            l.template :default
            l.gift_message 51
          end

          d.po_40(:align => :left, :trim => false) do |l|
            l.trap { |line| line[0, 2] == '40' }
            l.template :default
            l.line_item_po_number 10
            l.spacer 12
            l.item_number 20
            l.spacer 3
            l.line_level_backorder_code 1
            l.special_action_code 2
            l.spacer 1
            l.item_number_type 2
          end

          d.po_41(:align => :left, :trim => false) do |l|
            l.trap { |line| line[0, 2] == '41' }
            l.template :default
            l.client_item_list_price 8
            l.line_level_backorder_cancel_date 6
            l.line_level_gift_wrap_code 3
            l.order_quantity 7
            l.clients_proprietary_item_numbere 20
            l.spacer 7
          end

          d.po_42(:align => :left, :trim => false) do |l|
            l.trap { |line| line[0, 2] == '42' }
            l.template :default
            l.line_level_gift_message 51
          end

          d.po_45(:align => :left, :trim => false) do |l|
            l.trap { |line| line[0, 2] == '45' }
            l.template :default
            l.imprint_code 1
            l.imprint_text_and_symbols 30
            l.imprint_font_code 1
            l.imprint_color_code 1
            l.imprint_position_code 1
            l.imprint_append_code 1
            l.spacer 16
          end

          d.po_50(:align => :left, :trim => false) do |l|
            l.trap { |line| line[0, 2] == '50' }
            l.template :default
            l.total_purchase_order_records 5
            l.total_line_items_in_file 10
            l.total_units_ordered 10
            l.spacer 26
          end
          d.po_90(:align => :left, :trim => false) do |l|
            l.trap { |line| line[0, 2] == '90' }
            l.record_code 2
            l.sequence_number 5
            l.total_line_item_in_file 13
            l.total_purchase_order_records 5
            l.total_units_ordered 10
            l.record_count_00 5
            l.record_count_10 5
            l.record_count_20 5
            l.record_count_30 5
            l.record_count_40 5
            l.record_count_50 5
            l.record_count_60 5
            l.record_count_70 5
            l.record_count_80 5
          end

        end


      end

      it "should have 80 characters in each line" do
        file = File.new(@po_file.path, "r")
        while (line = file.gets)
          line = line.chomp
          if line.mb_chars.length != 80
            fields = line.unpack('a2a5a7a5a13a6a22a3a7a5a1a4*')
            fields.each { |f| puts "#{f.length}: '#{f}'" }
            puts "Invalid Length #{line.length}]: #{line}"
            line.split(//).each_with_index { |c, i| puts "#{i}: '#{c}'" }
          end
          line.length.should == 80
        end
        file.close
      end

      it "should format po_00 correctly" do
        record = @parsed[:po_00]
        record.length.should == 1
        record = record.first
        should_match(record, {:record_code => '00',
                              :sequence_number => '00001',
                              :file_name => @po_file.file_name,
                              :format_version => 'F03',
                              :ingram_san => '1697978',
                              :vendor_name_flag => 'I',
                              :product_description => 'CDFL'
        })
        record[:creation_date].should =~ /\d{6}/
      end

      it "should format po_10 correctly" do
        record = @parsed[:po_10]
        record.length.should == 1
        should_match(record.first, {:record_code => '10',
                                    :sequence_number => '00002',
                                    :ingram_bill_to_account_number => Cdf::Config[:cdf_bill_to_account],
                                    :vendor_san => '1697978',
                                    :order_date => @order.completed_at.strftime("%y%m%d"),
                                    :backorder_cancel_date => (@order.completed_at + 3.months).strftime("%y%m%d"),
                                    :backorder_code => Records::Po::Po10::BACKORDER_CODE[:do_not_backorder],
                                    :ddc_fulfillment => 'N',
                                    :ship_to_indicator => 'Y',
                                    :bill_to_indicator => 'Y'})
      end

      it "should format po_20 correctly" do
        record = @parsed[:po_20]
        record.should == nil
      end

      it "should format po_21 correctly" do
        record = @parsed[:po_21]
        record.length.should == 1
        should_match(record.first, {:record_code => '21',
                                    :ingram_ship_to_account_number => Cdf::Config[:cdf_ship_to_account],
                                    :sequence_number => '00004',
                                    :po_number => @order.number.ljust_trim(22),
                                    :po_type => PoFile::PO_TYPE[:test_purchase_order],
                                    :dc_code => '',
                                    :green_light => 'Y',
                                    :poa_type => Records::Po::Po21::POA_TYPE[:full_acknowledgement],
                                    :ship_to_password => Cdf::Config[:cdf_ship_to_password],
                                    :carrier_shipping_method => '### USA ECONOMY',
                                    :split_order_allowed => 'Y'})

        should_match(record.first, :split_shipment_type => Order::SPLIT_SHIPMENT_TYPE[:release_when_full])
      end

      it "should format po_40 correctly" do
        record = @parsed[:po_40]
        record.should_not == nil
        record.length.should == 2
      end


      it "should format po_32 correctly" do
        record = @parsed[:po_32]
        record.length.should == 2
        [:address1, :address2].each_with_index do |field, i|
          record[i][:recipient_address_line].should == @order.ship_address.send(field)
        end
      end

      it "should format po_34 correctly" do
        records = @parsed[:po_34]
        records.length.should == 1
        record = records[0]
        
          record[:recipient_city].should == @order.ship_address.city
          record[:recipient_postal_code].should == @order.ship_address.zipcode
          record[:recipient_state].should == @order.ship_address.state.abbr
          record[:recipient_country].should == @order.ship_address.country.iso3
        
        
      end


    end

  end
end

def should_match(record, hash)
  hash.each_key do |key|
    record[key].should == hash[key]
  end
end