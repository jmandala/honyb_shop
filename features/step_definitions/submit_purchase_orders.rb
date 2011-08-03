Given /^the orders? (?:is|are) completed$/ do
  Order.all.each {|order| complete_order order }
end

Given /^the orders? (?:has|have) (\d+) line items? with a quantity of (\d+)$/ do |item_count, quantity|
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
  Order.needs_po.each {|o| @orders << o}
  @po_file = PoFile.generate
end


Then /^the purchase order should contain the (\d+)? ?given orders?$/ do |order_count|
  order_count ||= 1
  @po_file.orders.count.should == order_count.to_i
  (@po_file.orders - @orders).size.should == 0
end

def complete_order(order)
  order.bill_address = Factory(:address)
  order.ship_address = Factory(:address)
  order.shipping_method = Factory(:shipping_method)

  order.next # cart -> address
  order.next # address -> delivery
  order.next # delivery -> payment

  payment = order.payments.create(
      :amount => order.total,
      :source => Factory(:creditcard),
      :payment_method => Factory(:bogus_payment_method)
  )

  order.next # payment -> confirm
  order.next # confirm -> complete

  # simulate CC capture
  payment.complete

  # update totals
  order.update!
end

def add_line_item(order, quantity=1, variant=Factory(:in_stock_product).master)
  order.add_variant variant, quantity
end