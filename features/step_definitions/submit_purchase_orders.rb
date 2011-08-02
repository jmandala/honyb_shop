When /^I create a purchase order$/ do
  Order.needs_po.count.should == 1
  @order = Order.needs_po.first
  @po_file = PoFile.generate
end

Then /^the purchase order should contain the given order$/ do
  print @po_file.to_yaml
  @po_file.orders.count.should == 1
  @po_file.orders.first.should == @order
end