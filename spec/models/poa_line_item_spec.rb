require 'spec_helper'

describe PoaLineItem do

  context "when creating a new instance" do
    before(:all) do
      #noinspection RubyInstanceVariableNamingConvention
      @p = FactoryGirl.create :poa_line_item
    end

    it "should have default values" do
      @p.poa_order_header.should_not == nil
      @p.line_item.should_not == nil
      @p.po_number.should_not == nil
      @p.product.should_not == nil
      @p.record_code.should == '40'
    end

    it "should have a sequence number" do
      @p.sequence_number.should_not == nil
      @p.sequence_number.to_i > 0
    end

    it "should #find_self" do
      PoaLineItem.find_self(@p.poa_file, @p.sequence_number).should == @p
    end
  end

end