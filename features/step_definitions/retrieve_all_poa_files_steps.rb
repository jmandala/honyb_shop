Given /^(\d+) purchase order was submitted$/ do |count|
  Given "2 orders exist"
  And "each order has 1 line item with a quantity of 1"
  And "each order is completed"

  @po_file = PoFile.generate
end

When /^I download a POA$/ do
  @downloaded = PoaFile.download
end

Then /^the POA will reference the purchase order$/ do
  @downloaded.size.should == 1
  poa_file = @downloaded.first
  puts poa_file.file_name
  puts @po_file.file_name
end