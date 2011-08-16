require "spec_helper"

describe "test factories" do
  it "should save an order, and retrieve and order" do
    order = FactoryGirl.create(:order, :number => 'R674657678')
    result = Order.find_by_number!('R674657678')
    
    order.id.should == result.id
    order.number.should == result.number
  end
  
end
