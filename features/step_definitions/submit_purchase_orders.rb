When /^I create a Purchase Order$/ do
  Order.count.should == 1
  print Order.needs_po.count
  print Order.first.to_yaml
  @po_file = PoFile.generate
end

Then /^the Purchase Order should contain the given Order$/ do
  print @po_file.to_yaml
  @po_file.orders.count.should == 1
end
