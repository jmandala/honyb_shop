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

  context "When duplicating an order" do

    before :all do
      @original = Cdf::OrderBuilder.completed_test_order
      @duplicate = @original.duplicate
    end

    it "should have same line items" do
      original_items = @original.line_items.collect { |li| {li.variant => li.quantity} }
      duplicate_items = @duplicate.line_items.collect { |li| {li.variant => li.quantity} }
      original_items.should == duplicate_items
    end
    
    it "should have the same billing address" do
      @duplicate.bill_address.should == @original.bill_address
    end
    
    it "should have the same shipping address" do
      @duplicate.ship_address.should == @original.ship_address
    end
    
    it "should have the same shipping method" do
      @duplicate.shipping_method.should == @original.shipping_method
    end
    
    it "should have the same special instructions" do
      @duplicate.special_instructions.should == @original.special_instructions
    end
    
    it "should have the same split_shipment_type" do
      @duplicate.split_shipment_type.should == @original.split_shipment_type
    end
    
    it "should have the same order_type" do
      @duplicate.order_type.should == @original.order_type
    end
    
    it "should have bi-directional reference" do
      @duplicate.parent.should == @original
      @original.children.include?(@duplicate).should == true
    end

    it "should have email" do
      @duplicate.email.should == @original.email
    end
    
    it "should have an order name" do
      @duplicate.order_name.should == "Duplicate of #{@original.number}: #{@original.order_name}"
    end
    
  end
end
