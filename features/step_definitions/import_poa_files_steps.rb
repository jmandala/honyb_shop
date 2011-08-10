Given /^a purchase order was submitted with (\d+) orders?$/ do |count|
  Given "#{count} orders exist"
  And "each order has 1 line item with a quantity of 1"
  And "each order is completed"

  @po_file = PoFile.generate
  @po_file.orders.size.should == count.to_i
  @po_file.put

end

Given /^a POA file exists on the FTP server$/ do
  poa_file_name = @po_file.file_name.gsub /fbo$/, 'fbc'

  CdfFtpClient.new.connect do |ftp|

    remote_files = []

    5.times do
      if remote_files.length > 0
        break
      end
      sleep 5
      remote_files = ftp.list("outgoing/#{poa_file_name}")
    end

    remote_files.length.should == 1
  end
end


When /^I download a POA$/ do
  @downloaded = PoaFile.download
end

When /^I import all POA files$/ do
  @imported = PoaFile.import_all
  @poa_file = PoaFile.first
end

Then /^there should be no more files to download$/ do
  PoaFile.remote_files.size.should == 0
end

Then /^there should be one POA file$/ do
  PoaFile.all.count.should == 1
end

Then /^I should have downloaded (\d+) files?$/ do |count|
  @downloaded.size.should == count.to_i
end

Then /^the POA file should be named according to the PO File$/ do
  @downloaded.first.file_name.gsub(/fbc$/, 'fbo').should == @po_file.file_name
end

Then /^the PO File should reference the POA$/ do
  @po_file.reload
  @po_file.poa_files.size.should == 1
  @po_file.poa_files.first.should == @poa_file
end

Then /^the POA Type should be valid$/ do
  @poa_file.poa_type.should_not == nil
end

Then /^the POA should reference the orders in the PO File$/ do
  @poa_file.orders.count.should == @po_file.orders.count

  @poa_file.orders.each do |o|
    @po_file.orders.include?(o).should == true
  end


end