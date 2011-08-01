When /^I create a Purchase Order$/ do
  Order.needs_po.count.should == 1
  @order = Order.needs_po.first
  @po_file = PoFile.generate
end

Then /^the Purchase Order should contain the given Order$/ do
  print @po_file.to_yaml
  @po_file.orders.count.should == 1
  @po_file.orders.first.should == @order
end

Then /^the given Order should have a shipment state of "([^"]*)"$/ do |shipment_state|
  @order.shipment_state.should == shipment_state
end
