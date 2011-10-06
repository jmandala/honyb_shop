describe Shipment do
  
  let(:order) { mock_model(Order, :completed? => true, :canceled? => false, :payment_state => 'complete', :update! => true) }
  let(:inventory_unit) { mock_model(InventoryUnit, :ship! => true) }
  
  
  it "should not send an email after_ship" do
    shipment = Shipment.new(:order => order, :shipping_method => mock_model(ShippingMethod))
    shipment.stub(:inventory_units) { [inventory_unit]}
    shipment.stub(:ensure_correct_adjustment)
    shipment.stub(:udate_order)
    
    ShipmentMailer.should_not_receive(:shipped_email).with(shipment)

    shipment.stub(:state) {'ready'}    
    shipment.ship!
  end
end