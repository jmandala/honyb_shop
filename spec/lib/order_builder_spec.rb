require_relative '../spec_helper'

describe Cdf::OrderBuilder do
  before(:all) do
    @builder = Cdf::OrderBuilder
  end
  
  
  it "should have a list of scenarios" do
    @builder::SCENARIOS.should_not == nil
  end
  
  it "should create a new test order" do
    order = @builder.completed_test_order
    #noinspection RubyResolve
    order.errors.should == {}
    order.id.should_not == nil
    order.id.should > 0
    order.line_items.count.should == 1
    order.payment.source.should_not == nil
    order.payment.payment_method.should_not == nil
    order.payment.payment_method.environment.should == ENV['RAILS_ENV']
    order.payment.state.should == 'completed'
    order.outstanding_balance.should == 0
    order.complete?.should == true
  end
  
  it "should find the scenario by ID" do
    @builder.find_scenario(1)[:name].should == @builder::SCENARIOS[0][:name]
    @builder.find_scenario(2)[:name].should == @builder::SCENARIOS[1][:name]
  end
  
  it "should create a new order by scenario number" do
    order = @builder.completed_test_order @builder.find_scenario(1)
    order.line_items.count.should == 1
    order.line_items[0].quantity.should == 1
    order.should_not == nil    
  end
  
  it "should create a new order with quantity of two" do
    order = @builder.completed_test_order @builder.find_scenario(2)
    order.line_items.count.should == 1
    order.line_items[0].quantity.should == 2
  end
  
  it "should create a new order with two line items" do
    order = @builder.completed_test_order @builder.find_scenario(3)
    order.line_items.count.should == 2
    order.line_items[0].quantity.should == 1
  end
  
  it "should create a new order with two line items and quantity of two" do
    order = @builder.completed_test_order @builder.find_scenario(4)
    order.line_items.count.should == 2
    order.line_items.each {|li| li.quantity.should == 2 }
  end
  
  it "should create new orders for each scenario id in array" do
    orders = @builder.create_for_scenarios [1,2,3]
    orders.count.should == 3
  end
  
  
end