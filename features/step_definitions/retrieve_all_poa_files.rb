Given /^(\d+) purchase order was submitted$/ do |count|
  Given "2 orders exist"
  And "each order has 1 line item with a quantity of 1"
  And "each order is completed"

  @po_file = PoFile.generate
end

When /^I retrieve a POA$/ do
  @poa_file = PoaFile.retrieve
end

Then /^the POA will reference the purchase order$/ do
  pending # express the regexp above with the code you wish you had
end