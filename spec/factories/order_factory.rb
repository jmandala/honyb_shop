FactoryGirl.define do

  factory :in_stock_product, :parent => :product do
    on_hand 1000
    sku '9780373200009'
  end

  factory :order_address, :aliases => [:bill_address, :ship_address], :parent => :address

  factory :completed_order, :parent => :order do
    #noinspection RubyResolve
    bill_address

    #noinspection RubyResolve
    ship_address

    shipping_method

    # add line items
    after_build { |order| order.add_variant Factory(:in_stock_product).master }

    after_create do |order|

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

  end

end