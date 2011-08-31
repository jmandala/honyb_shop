require_relative '../spec_helper'

describe 'OrderBuilder' do
  it "should have a list of scenarios" do
    Cdf::OrderBuilder::SCENARIOS.should_not == nil
  end
  
  it "should create a new test order" do
    order = Cdf::OrderBuilder.new_test
    #noinspection RubyResolve
    order.errors.should == {}
    order.id.should_not == nil
    order.id.should > 0
  end
  
end