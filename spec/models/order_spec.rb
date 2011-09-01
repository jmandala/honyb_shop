require_relative '../spec_helper'

describe Order do

  context "When working with a new Order" do

    before(:each) do 
      @order = Order.new
    end
    
    it "should be live by default" do
      @order.live?.should == true
      @order.test?.should == false
    end

    it "should allow for setting order_type to test" do
      @order.test?.should == false
      @order.to_test
      @order.test?.should == true
      @order.live?.should == false
    end
    
    it "should raise exception if order is completed" do
      @order.completed_at = Time.now
      result = ''
      begin 
        @order.to_test
      rescue Cdf::IllegalStateError => e
        result = e
      end
      
      result.class.should == Cdf::IllegalStateError
    end
  end
end