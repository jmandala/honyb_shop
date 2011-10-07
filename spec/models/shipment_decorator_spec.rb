describe Shipment do
  
  let(:order) { mock_model(Order, :completed? => true, :canceled? => false, :payment_state => 'complete', :update! => true) }
  let(:inventory_unit) { mock_model(InventoryUnit, :ship! => true, :[]= => true, :save => true, :state => 'sold') }
  let(:shipping_method) { mock_model(ShippingMethod, :create_adjustment => true)}
  let(:shipment) { Shipment.new(:order => order, :shipping_method => shipping_method, :inventory_units => [inventory_unit]) }
  
  it "should not send an email after_ship" do
    shipment.stub(:ensure_correct_adjustment)
    shipment.stub(:udate_order)
    
    ShipmentMailer.should_not_receive(:shipped_email).with(shipment)
    shipment.stub(:state) {'ready'}    
    shipment.ship!
  end
  
  it "should remove all unsold inventory" do
    shipment.stub(:ensure_correct_adjustment)
    shipment.inventory_units.should == [inventory_unit]
    shipment.unassign_sold_inventory.should == shipment
    shipment.inventory_units.should == []
  end
  
end