require 'spec_helper'

describe Shipment do

  let(:order) { mock_model(Order, :completed? => true, :canceled? => false, :payment_state => 'complete', :update! => true) }
  let(:inventory_unit) { mock_model(InventoryUnit, :ship! => true, :[]= => true, :save => true, :state => 'sold', :state? => true) }
  let(:shipping_method) { mock_model(ShippingMethod, :create_adjustment => true) }
  let(:shipment) { Shipment.new(:order => order, :shipping_method => shipping_method, :inventory_units => [inventory_unit]) }

  it "should not send an email after_ship" do
    shipment.stub(:ensure_correct_adjustment)
    shipment.stub(:udate_order)

    ShipmentMailer.should_not_receive(:shipped_email).with(shipment)
    shipment.stub(:state) { 'ready' }
    shipment.ship!
  end

  context "manage children" do
    before :all do
      @builder = Cdf::OrderBuilder

      @order = @builder.completed_test_order({:id => 1,
                                              :name => 'single order/multiple quantity',
                                              :line_item_count => 1,
                                              :line_item_qty => 10})
      @shipment = @order.shipments.first
    end

    it "should be possible to create a child shipment" do
      @shipment.children.should == []

      inventory_unit = InventoryUnit.new
      child_1 = @shipment.create_child([inventory_unit])
      @shipment.children.count.should == 1
      @shipment.children.first.should == child_1
      child_1.parent.should == @shipment
      child_1.inventory_units.should == [inventory_unit]

      child_2 = @shipment.create_child([InventoryUnit.new])
      @shipment.children.count.should == 2
      @shipment.children.should == [child_1, child_2]
      child_2.parent.should == @shipment
    end

    it "should transfer values to the child" do
      child = @shipment.create_child([InventoryUnit.new])
      [:order, :shipping_method, :address].each { |k| child.send(k).should == @shipment.send(k)}
    end
  end

end