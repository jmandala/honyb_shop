require 'spec_helper'

describe PoaLineItemPubRecord do

  after(:all) do
    PoaFile.all.each { |p| p.destroy }
    LineItem.all.each { |l| l.destroy }
  end

  context "when creating a new instance" do
    before(:all) do
      #noinspection RubyInstanceVariableNamingConvention
      @p = FactoryGirl.create :poa_line_item_pub_record
    end

    it "should have record code 43" do
      @p.record_code.should == '43'
    end

    it "should have a poa_order_header" do
      @p.poa_order_header.should_not == nil
    end

    it "should have a order number" do
      @p.po_number.should == @p.poa_order_header.order.number
    end

    it "should have a total_qty_predicted_to_ship_primary" do
      @p.total_qty_predicted_to_ship_primary.should_not == nil
    end

    it "should have a publication_release_date" do
      @p.publication_release_date.should_not == nil
    end

    it "should have a publisher_name" do
      @p.publisher_name.should_not == nil
    end

    it "should have an original_seq_number" do
      @p.original_seq_number.should_not == nil
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
        instance_variable_set "@poa_line_item_pub_record_#{i}", FactoryGirl.create(:poa_line_item_pub_record, :poa_order_header => @poa_order_header_1)
      end
    end


    it "should reference the corresponding poa_line_item" do
      @order_1.line_items.count.should == 3
      @poa_order_header_1.poa_line_items.count.should == 3
      @poa_order_header_1.poa_additional_details.count.should == 3
      @poa_order_header_1.poa_line_item_pub_records.count.should == 3

      # each poa_additional_detail should reference the corresponding poa_line_item
      3.times do |i|
        poa_line_item_pub_record = instance_variable_get "@poa_line_item_pub_record_#{i}"
        poa_line_item_pub_record.should_not == nil
        poa_line_item = instance_variable_get "@poa_line_item_#{i}"
        poa_line_item.should_not == nil
        poa_line_item_pub_record.poa_line_item.should == nil
        poa_line_item_pub_record.nearest_poa_line_item.should == poa_line_item
      end
    end

  end

end