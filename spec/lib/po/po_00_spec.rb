require 'spec_helper'

describe Records::Po::Po00 do

  before(:each) do
    @order = Factory(:order)
    add_line_item @order
    complete_order @order

    @po_file = PoFile.generate

  end

  context "when creating a purchase order" do
    context "and the order has a single line item" do
      before(:each) do
        @po_00 = Records::Po::Po00.new('test_file')
      end

      it "should have 80 characters" do
        @po_00.cdf_record.length.should == 80
      end

      it "should have correct format" do
        @po_00.cdf_record.should == "00000010000000     HonyB        #{@order.completed_at.strftime("%y%m%d")}test_file             F031697978     ICDFL"
      end

    end
  end
end