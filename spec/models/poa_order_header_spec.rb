require_relative "../spec_helper"

describe "PoaOrderHeader" do
  context "when creating an instance" do

    before(:all) do
      @poa_order_header = FactoryGirl.create(:poa_order_header)
    end

    it "should should have all instance values" do
      @poa_order_header.record_code.should == '11'
      @poa_order_header.poa_file.should_not == nil
      @poa_order_header.order.should_not == nil
      @poa_order_header.po_number.should == @poa_order_header.order.number
      @poa_order_header.po_number.should == @poa_order_header.order_number
      @poa_order_header.poa_vendor_records.should == []
      @poa_order_header.poa_ship_to_name.should == nil
      @poa_order_header.poa_address_lines.should == []
      @poa_order_header.poa_line_items.should == []
      @poa_order_header.poa_additional_details.should == []
      @poa_order_header.poa_line_item_title_records.should == []
      @poa_order_header.poa_line_item_pub_records.should == []
      @poa_order_header.poa_item_number_price_records.should == []
      @poa_order_header.poa_order_control_total.should == nil
    end
  end
end
