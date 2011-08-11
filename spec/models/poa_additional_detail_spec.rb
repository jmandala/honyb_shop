require 'spec_helper'

describe PoaAdditionalDetail do

  after(:all) do
    PoaFile.all.each { |p| p.destroy }
    LineItem.all.each { |l| l.destroy }
  end

  context "when creating a new instance" do
    before(:all) do
      @pad = FactoryGirl.create :poa_additional_detail
    end

    after(:all) do
      poa_file = @pad.poa_file
      poa_file.destroy
    end

    it "should have default values" do
      @pad.availability_date.should_not == nil
      @pad.po_number.should_not == nil
      @pad.poa_order_header.should_not == nil
    end

    it "should have a sequence number" do
      @pad.sequence_number.should_not == nil
      @pad.sequence_number.to_i > 0
    end

    it "should delegate poa_file" do
      @pad.poa_file.should == @pad.poa_order_header.poa_file
    end

    it "should #find_self" do
      PoaAdditionalDetail.find_self(@pad.poa_file, @pad.sequence_number).should == @pad
    end
  end

  context "when created during an import" do

    before(:all) do
      @order_1 = FactoryGirl.create :order

      # variants, line items
      3.times do |i|
        instance_variable_set "@variant_#{i}", FactoryGirl.create(:variant, :sku => i)
        instance_variable_set "@line_item_#{i}", FactoryGirl.create(:line_item, :order => @order_1, :variant => instance_variable_get("@variant_#{i}"))
      end

      # poa_file
      @poa_file = FactoryGirl.create :poa_file
      @poa_order_header_1 = FactoryGirl.create :poa_order_header, :poa_file => @poa_file

      # poa_line_items, poa_additional_details
      3.times do |i|
        instance_variable_set "@poa_line_item_#{i}", FactoryGirl.create(:poa_line_item, :poa_order_header => @poa_order_header_1)
        instance_variable_set "@poa_additional_detail_#{i}", FactoryGirl.create(:poa_additional_detail, :poa_order_header => @poa_order_header_1)
      end
    end


    it "should reference the corresponding poa_line_item" do
      @order_1.line_items.count.should == 3
      @poa_order_header_1.poa_line_items.count.should == 3
      @poa_order_header_1.poa_additional_details.count.should == 3

      # each poa_additional_detail should reference the corresponding poa_line_item
      3.times do |i|
        poa_additional_detail = instance_variable_get "@poa_additional_detail_#{i}"
        poa_additional_detail.should_not == nil
        poa_line_item = instance_variable_get "@poa_line_item_#{i}"
        poa_line_item.should_not == nil
        poa_additional_detail.poa_line_item.should == nil
        puts "my sequence: #{poa_additional_detail.sequence_number}"
        poa_additional_detail.nearest_poa_line_item.should == poa_line_item
      end


    end

  end


end