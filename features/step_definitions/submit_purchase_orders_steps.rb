Given /^each order is completed$/ do
  Order.all.each { |order| complete_order order }
end

Given /^each order has (\d) line item with a quantity of (\d)$/ do |item_count, quantity|
  skus = %w(9780373200009 978037352805 978037352812 978037352829)
  item_count = item_count.to_i - 1
  (0..item_count).each do |index|
    Order.all.each do |order|
      add_line_item order, quantity, Factory(:in_stock_product, :sku => skus[index]).master
    end
  end
end

When /^I create a purchase order$/ do
  Order.needs_po.count.should > 0

  @orders = []
  Order.needs_po.each { |o| @orders << o }

  @po_file = PoFile.generate
end

When /^I send the purchase order to the FTP server$/ do
  @po_file.put
end

Then /^the FTP server should contain the file in either the (\w+) or (\w+) folder$/ do |folder_1, folder_2|
  CdfFtpClient.new.connect do |ftp|
    folder_1_files = ftp.list "#{folder_1}/#{@po_file.file_name}"
    folder_2_files = ftp.list "#{folder_2}/#{@po_file.file_name}"

    (folder_1_files.length + folder_2_files.length).should == 1
  end

end


Then /^the purchase order should contain (\d+) orders?$/ do |order_count|
  order_count ||= 1
  @po_file.orders.count.should == order_count.to_i
  (@po_file.orders - @orders).size.should == 0
end

Then /^the purchase order file name should be formatted hb-YYMMDDHHMMSS.fbo$/ do
  match = /^hb-(\d{2})(\d{2})(\d{2})(\d{2})(\d{2})(\d{2}).fbo/.match(@po_file.file_name)
  match.should_not == nil
  year, month, day, hour, min, sec = match.captures
  time = @po_file.created_at
  year.should == time.strftime("%y").to_s
  month.should == time.strftime("%m").to_s
  day.should == time.strftime("%d").to_s
  hour.should == time.strftime("%H").to_s
  min.should == time.strftime("%M").to_s
  sec.should == time.strftime("%S").to_s

  puts @po_file.data

  @po_file.delete_file
end

Then /^the purchase order file character count should be divisible by (\d+)$/ do |count|
  char_count = @po_file.data.split(//).length
  (char_count % 80).should == 0
end