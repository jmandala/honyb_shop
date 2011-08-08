Given /^(\d+) purchase order was submitted$/ do |count|
  Given "2 orders exist"
  And "each order has 1 line item with a quantity of 1"
  And "each order is completed"

  @po_file = PoFile.generate
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

Then /^the POA will reference the purchase order$/ do
  @downloaded.size.should > 0

  found = nil
  @downloaded.each do |poa_file|
    file_name = poa_file.file_name.gsub(/\.fbc/, '.fbo')
    if file_name == @po_file.file_name
      found = poa_file
      break
    end
  end

  found.should_not == nil

  @po_file.poa_files.size.should > 0

end