require_relative '../spec_helper'

describe PoaLineItem do

  context "when creating a new instance" do
    before :each do
      #noinspection RubyInstanceVariableNamingConvention
      @p = FactoryGirl.create :poa_line_item
    end


    it "should have an order header" do
      @p.poa_order_header.should_not == nil
    end

    it "should have a line item" do
      @p.line_item.should_not == nil
    end

    it "should have a po_number" do
      @p.po_number.should_not == nil
    end

    it "should have a record code" do
      @p.record_code.should == '40'
    end

    it "should have a poa_status" do
      @p.poa_status.code == '00'
    end

    it "should have a dc code" do
      @p.dc_code.po_dc_code == 'N'
      @p.dc_code.poa_dc_code == 'N'
      @p.dc_code.asn_dc_code == 'NV'
      @p.dc_code.inv_dc_san == '1697978'
      @p.dc_code.dc_name == 'La Vergne, Tennessee'
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