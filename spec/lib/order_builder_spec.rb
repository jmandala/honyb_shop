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
    order = @builder.completed_test_order({:id => 5, :name => 'single order/multiple lines/multiple quantity: Hawaii', :line_item_count => 2, :line_item_qty => 2, :state_abbr => :HI})
    order.ship_address.state.abbr.should == 'HI'
    order.ship_address.country.iso3.should == 'USA'
    economy_mail = ShippingMethod.find_by_name 'Economy Mail'
    order.shipping_method.should == economy_mail
  end

  it "should create order for USVI" do
    order = @builder.completed_test_order({:id => 5, :name => 'single order/multiple lines/multiple quantity: Hawaii', :line_item_count => 2, :line_item_qty => 2, :state_abbr => :VI})
    order.ship_address.state.abbr.should == 'VI'
    order.ship_address.country.iso3.should == 'VIR'
    economy_mail = ShippingMethod.find_by_name 'Economy Mail'
    order.shipping_method.should == economy_mail
  end

  it "should specify the shipping method" do
    order = @builder.completed_test_order({:id => 5, :name => '2nd Day Air', :shipping_method => '2nd Day Air'})
    shipping_method = ShippingMethod.find_by_name '2nd Day Air'
    order.shipping_method.should == shipping_method
  end
  
  it "should specify the invalid shipping method" do
    order = @builder.completed_test_order({:id => 5, :name => 'Invalid shipping method', :shipping_method => 'Invalid Shipping Method'})
    shipping_method = ShippingMethod.find_by_name('Invalid Shipping Method')
    order.shipping_method.should == shipping_method
  end

  context "ean_type" do
    it "should specify the ean" do
      order = @builder.completed_test_order({:id => 5, :name => 'not yet received ean', :ean_type => :not_yet_received})
      order.line_items.count.should == 1
      product_builder = Cdf::ProductBuilder.new
      order.line_items.first.variant.sku.no_dashes.should == product_builder.next_sku(:not_yet_received).no_dashes
    end

    it "should specify multiple eans" do
      order = @builder.completed_test_order({:id => 5, :name => 'multiple eans', :ean_type => [:in_stock, :not_yet_received]})
      order.line_items.count.should == 2
      order.line_items[0].variant.sku.no_dashes.should == "978-0-3732-0000-9".no_dashes
      order.line_items[1].variant.sku.no_dashes.should == "9782914563383".no_dashes
    end

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
        @builder.create_address({:state_abbr => :xyz})
      rescue => e
        error = e
      end

      error.class.should == ActiveRecord::RecordNotFound
      error.message.should == "Couldn't find State with abbr = xyz"
    end

    it "creates a domestic address" do
      address = @builder.create_address({:state_abbr => :ME})
      address.state.abbr.should == 'ME'
      address.country.iso3.should == 'USA'
    end

    it "creates a foreign address" do
      address = @builder.create_address({:state_abbr => :PR})
      address.state.abbr.should == 'PR'
      address.country.iso3.should == 'PRI'
      address.country.numcode.should == 630
    end

    it "creates an APO/FPO address" do
      address = @builder.create_address({:state_abbr => :AE})
      address.state.name.should == 'Armed Forces Africa'
      address.country.iso3.should == 'USA'
      address.country.numcode.should == 840
    end

    it "creates a PO Box address" do
      address = @builder.create_address({:address1 => 'P. O. Box 123'})
      address.address1.match(/p\.?\s*o\.?\s*box/i).should_not == nil
    end
  end


  context "dc codes" do
    it "should specify the default dc code" do
      order = @builder.completed_test_order({:id => 1, :name => 'default'})
      order.dc_code.should == DcCode.default
    end

    it "should specify the Chambersburg dc code" do
      order = @builder.completed_test_order({:id => 1, :name => 'chambersburg', :dc_code => 'C'})
      order.dc_code.should == DcCode.find_by_po_dc_code('C')
    end
  end


  context "split shipment types" do

    it "should specify a default split shipment type" do
      order = @builder.completed_test_order({:id => 23, :name => 'split shipment: default'})
      order.split_shipment_type.should == Order::SPLIT_SHIPMENT_TYPE[:release_when_full]
    end

    it "should specify dual shipment" do
      order = @builder.completed_test_order({:id => 23, :name => 'split shipment: DS', :split_shipment_type => :dual_shipment})
      order.split_shipment_type.should == Order::SPLIT_SHIPMENT_TYPE[:dual_shipment]
    end
  end

  it "should specify an order number" do
    order = @builder.completed_test_order({:id => 23, :name => 'split shipment: default'})
  end

  it "should set an order comment" do
    order = @builder.completed_test_order({:id => 23, :name => 'set test order'})
    order.comments.count.should == 1
    order.comments.first.comment.should == 'set test order'
    order.comments.first.comment_type.name.should == 'Order Name'
    order.order_name.should == 'set test order'
  end

end