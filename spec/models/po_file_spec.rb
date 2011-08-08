require 'spec_helper'

describe PoFile do


  context "when creating a purchase order" do

    before(:all) do
      Spree::Config.set({:cdf_ship_to_account => '1234567'})
      Spree::Config.set({:cdf_ship_to_password => '12345678'})
      Spree::Config.set({:cdf_bill_to_account => '1234567'})

      
      @order = Factory(:order)
      add_line_item @order
      complete_order @order
      @po_file = PoFile.generate
      puts "\n" + @po_file.data

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

      @parsed = FixedWidth.parse(File.new(@po_file.path), :po_file)
    end


    after(:all) do
      @po_file.delete_file
    end

    it "should have 80 characters in each line" do
      file = File.new(@po_file.path, "r")
      while (line = file.gets)
        line = line.chomp
        if line.mb_chars.length != 80
          fields = line.unpack('a2a5a7a5a13a6a22a3a7a5a1a4*')
          fields.each {|f| puts "#{f.length}: '#{f}'"}
          puts "Invalid Length #{line.length}]: #{line}"
          line.split(//).each_with_index { |c, i| puts "#{i}: '#{c}'"}
        end
        line.length.should == 80
      end
      file.close
    end

    it "should format po_00 correctly" do
      record = @parsed[:po_00]
      record.length.should == 1
      record = record.first
      record[:record_code].should == '00'
      record[:sequence_number].should == '00001'
      record[:file_source_san].should == '0000000'
      record[:creation_date].should =~ /\d{6}/
      record[:file_name].should == @po_file.file_name
      record[:format_version].should == 'F03'
      record[:ingram_san].should == '1697978'
      record[:vendor_name_flag].should == 'I'
      record[:product_description].should == 'CDFL'
    end

    it "should format po_10 correctly" do
      record = @parsed[:po_10]
      record.length.should == 1
      record = record.first
      record[:record_code].should == '10'
      record[:sequence_number].should == '00002'
      record[:ingram_bill_to_account_number].should == Spree::Config.get(:cdf_bill_to_account)
      record[:vendor_san].should == '1697978'
      record[:order_date].should == @order.completed_at.strftime("%y%m%d")
      record[:backorder_cancel_date].should == (@order.completed_at + 3.months).strftime("%y%m%d")
      record[:backorder_code].should == Records::Po::Po10::BACKORDER_CODE[:do_not_backorder]
      record[:ddc_fulfillment].should == 'N'
      record[:ship_to_indicator].should == 'Y'
      record[:bill_to_indicator].should == 'Y'
    end

    it "should format po_20 correctly" do
      record = @parsed[:po_20]
      record.should == nil
    end

    it "should format po_21 correctly" do
      record = @parsed[:po_21]
      record.length.should == 1
      record = record.first
      record[:record_code].should == '21'
      record[:ingram_ship_to_account_number].should == Spree::Config.get(:cdf_ship_to_account)
      record[:sequence_number].should == '00004'
      record[:po_number].should == @order.number.ljust_trim(22)
      record[:po_type].should == Records::Po::Po21::PO_TYPE[:purchase_order]
      record[:order_type].should == Records::Po::Po21::ORDER_TYPE[:release_when_full]
      record[:dc_code].should == ''
      record[:green_light].should == 'Y'
      record[:poa_type].should == Records::Po::Po21::POA_TYPE[:full_acknowledgement]
      record[:ship_to_password].should == Spree::Config.get(:cdf_ship_to_password)
      record[:carrier_shipping_method].should == '### 2ND DAY AIR'
      record[:split_order_allowed].should == 'Y'

    end
  end

end