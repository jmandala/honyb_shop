require 'spec_helper'

Spree::Config.set({:cdf_ship_to_account => '1234567'})
Spree::Config.set({:cdf_ship_to_password => '12345678'})
Spree::Config.set({:cdf_bill_to_account => '1234567'})

describe PoFile do

  before(:each) do
    @order = Factory(:order)
    add_line_item @order
    complete_order @order
    @po_file = PoFile.generate
  end

  context "when creating a purchase order" do

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

      d.po_21(:align => :left) do |l|
        l.trap { |line| line[0, 2] == '21' }
        l.template :default
        l.ingram_ship_to_account_number 7
        l.po_type 1
        l.order_type 2
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

    end

    before(:each) do
      po_file = File.new(@po_file.path)
      @parsed = FixedWidth.parse(po_file, :po_file)
    end

    it "should format po_00 correctly" do
      po_00 = @parsed[:po_00]
      po_00.length.should == 1
      po_00 = po_00.first
      po_00[:record_code].should == '00'
      po_00[:sequence_number].should == '00001'
      po_00[:file_source_san].should == '0000000'
      po_00[:creation_date].should == @po_file.created_at.strftime("%y%m%d")
      po_00[:file_name].should == @po_file.file_name
      po_00[:format_version].should == 'F03'
      po_00[:ingram_san].should == '1697978'
      po_00[:vendor_name_flag].should == 'I'
      po_00[:product_description].should == 'CDFL'
    end

    it "should format po_21 correctly" do
      po_21 = @parsed[:po_21]
      po_21.length.should == 1
      po_21 = po_21.first
      puts po_21.to_yaml
      po_21[:record_code].should == '21'
      po_21[:ingram_ship_to_account_number].should == Spree::Config.get(:cdf_ship_to_account)
      po_21[:sequence_number].should == '00003'
      po_21[:po_number].should == @order.number.ljust_trim(22)
      po_21[:po_type].should == Records::Po::Po21::PO_TYPE[:purchase_order]
      po_21[:order_type].should == Records::Po::Po21::ORDER_TYPE[:release_when_full]
      po_21[:dc_code].should == ''
      po_21[:green_light].should == 'Y'
      po_21[:poa_type].should == Records::Po::Po21::POA_TYPE[:full_acknowledgement]
      po_21[:ship_to_password].should == Spree::Config.get(:cdf_ship_to_password)
      po_21[:carrier_shipping_method].should == '### 2ND DAY AIR'
      po_21[:split_order_allowed].should == 'Y'

    end
  end

end