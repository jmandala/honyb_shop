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
    order.line_items.each { |li| li.quantity.should == 2 }
  end

  it "should create new orders for each scenario id in array" do
    orders = @builder.create_for_scenarios [1, 2, 3]
    orders.count.should == 3
  end

  it "should create order for Hawaii" do
    order = @builder.completed_test_order({:id => 5, :name => 'single order/multiple lines/multiple quantity: Hawaii', :line_item_count => 2, :line_item_qty => 2, :ship_location => :HI})
    order.ship_address.state.abbr.should == 'HI'
    order.ship_address.country.iso3.should == 'USA'
    economy_mail = ShippingMethod.find_by_name 'Economy Mail'
    order.shipping_method.should == economy_mail
  end
  
  it "should create order for USVI" do
    order = @builder.completed_test_order({:id => 5, :name => 'single order/multiple lines/multiple quantity: Hawaii', :line_item_count => 2, :line_item_qty => 2, :ship_location => :VI})
    order.ship_address.state.abbr.should == 'VI'
    order.ship_address.country.iso3.should == 'VIR'
    economy_mail = ShippingMethod.find_by_name 'Economy Mail'
    order.shipping_method.should == economy_mail
  end

  context "#create_address" do
    it "requires a state argument" do
      e = nil
      begin
        @builder.create_address
      rescue => e
        error = e
      end

      e.class.should == ArgumentError
    end

    it "should error when state is invalid" do
      error = nil
      begin
        @builder.create_address :xyz
      rescue => e
        error = e
      end

      error.class.should == ActiveRecord::RecordNotFound
      error.message.should == "Couldn't find State with abbr = xyz"
    end

    it "creates a domestic address" do
      address = @builder.create_address :ME
      address.state.abbr.should == 'ME'
      address.country.iso3.should == 'USA'
    end

    it "creates a foreign address" do
      address = @builder.create_address :PR
      address.state.abbr.should == 'PR'
      address.country.iso3.should == 'PRI'
      address.country.numcode.should == 630
    end

  end

end