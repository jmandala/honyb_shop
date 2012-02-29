require_relative "../spec_helper"

describe 'order_decorator' do

  let(:order) { Order.new }

  it "should have an array of children orders" do
    order.children.should == []
  end

  it "should have a nil parent" do
    order.parent.should == nil
  end

  it "should have an ORDER_NAME" do
    Order::ORDER_NAME.should == 'Order Name'
  end

  it "should define TYPES" do
    Order::TYPES.should == [:live, :test]
  end

  it "should define SPLIT_SHIPMENT_TYPE" do
    Order::SPLIT_SHIPMENT_TYPE.should == {:multi_shipment => 'EL', :release_when_full => 'RF', :dual_shipment => 'LS'}
  end

  context "associations" do
    it "should have a po_file" do
      order.po_file.should == nil
    end
    
    it "should have a dc_code" do
      order.dc_code.should == nil
    end
    
    it "should have poa_order_headers" do
      order.poa_order_headers.should == []
    end
  end

  it "should have no gift wrap fee" do
    order.gift_wrap_fee.should == 0
  end

  it "should not be a gift" do
    order.is_gift?.should == false
  end

  it "should have no gift message" do
    order.gift_message.should == ''
  end

  it "should have no tax_rate" do
    order.tax_rate.should == nil
  end

end


