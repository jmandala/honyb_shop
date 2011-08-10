FactoryGirl.define do

  factory :in_stock_product, :parent => :product do
    on_hand 1000
    sku '9780373200009'
  end

  factory :order_address, :aliases => [:bill_address, :ship_address], :parent => :address

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

def to_sym(string)
  string.strip.downcase.gsub(/\s+/, '_').to_sym
end