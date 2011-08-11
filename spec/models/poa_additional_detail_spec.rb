require 'spec_helper'

describe PoaAdditionalDetail do

  context "when creating a new instance" do
    before(:all) do
      @pad = FactoryGirl.create :poa_additional_detail
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

      @poa_file = FactoryGirl.create :poa_file
      @poa_order_header_1 = FactoryGirl.create :poa_order_header, :poa_file => @poa_file
      @poa_line_item = FactoryGirl.create :poa_line_item

    end

    it "should reference the poa_line_item" 

  end


end