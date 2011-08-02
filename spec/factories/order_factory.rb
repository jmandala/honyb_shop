FactoryGirl.define do

  factory :in_stock_product, :parent => :product do
    on_hand 1000
  end

  factory :completed_order, :parent => :order do
    association :bill_address, :factory => :address
    association :ship_address, :factory => :address
    shipping_method

    # add line items
    after_build { |order| order.add_variant Factory(:in_stock_product).master }

    after_create do |order|

      # cart -> address
      order.next

      # address -> delivery
      order.next

      # delivery -> payment
      payment = order.payments.create(
          :amount => order.total,
          :source => Factory(:creditcard),
          :payment_method => Factory(:bogus_payment_method)
      )

      order.next

      # confirm -> complete
      order.next

      # complete
      order.next

      payment.complete

      order.update!
    end

  end

end