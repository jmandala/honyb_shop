FactoryGirl.define do

  sequence :row_number do |n|
    sprintf "%05d", n
  end

  factory :cdf_binding_code do
    factory :mass_market do
      code 'M'
      name 'Mass Market'
    end
    factory :audio do
      code 'A'
      name 'Audio products'
    end
    factory :trade_paper do
      code 'T'
      name 'Trade Paper'
    end
    factory :hard_cover do
      code 'H'
      name 'Hard Cover'
    end
    factory :other do
      code ''
      name 'Other'
    end
  end

  factory :dc_code do
    factory :la_vergne do
      po_dc_code 'N'
      poa_dc_code 'N'
      asn_dc_code 'NV'
      inv_dc_san '1697978'
      dc_name 'La Vergne, Tennessee'
    end
    factory :chambersburg do
      po_dc_code 'C'
      poa_dc_code 'C'
      asn_dc_code 'CI'
      inv_dc_san '2544105'
      dc_name 'Chambersburg, Pennsylvania'
    end
  end

  factory :poa_status do
    factory :predicted_to_ship do
      code '00'
      name 'Predicted to Ship 100% of ordered product'
    end
    factory :cancelled_not_stocked do
      code '01'
      name 'Cancelled, Item Not Stocked'
    end
    factory :cancelled_os_no_backorder do
      code '02'
      name 'Cancelled, temporarily Out of Stock (OS), no Backorder'
    end
    factory :out_of_stock_backorder_request do
      code '03'
      name 'Out of Stock (OS), Backordered per Client request'
    end
  end

  factory :poa_file do
    file_name { "#{Time.now.strftime("%y%m%d%H%M%S")}.fbc" }
    sequence_number { Factory.next :row_number }
  end

  factory :poa_order_header do
    record_code '11'
    association :poa_file, :factory => :poa_file
    association :order, :factory => :order
    po_number { order.number }
    sequence_number { Factory.next :row_number }
    acknowledgement_date Time.now
    icg_san '1697978'
    icg_ship_to_account_number Cdf::Config.get(:cdf_ship_to_account_number)
    po_cancellation_date { Time.new + 3.months }
    #po_date { order.updated_at }
    toc 'C123456789012'
  end

  factory :poa_additional_detail do
    availability_date { Time.now }
    association :poa_order_header, :factory => :poa_order_header
    po_number { poa_order_header.order.number }
    sequence_number { Factory.next :row_number }
    record_code '41'
  end

  factory :poa_line_item do
    association :dc_code, :factory => :la_vergne
    line_item
    line_item_po_number { |p| p.line_item.id }
    poa_order_header
    po_number { |p| p.poa_order_header.po_number }
    association :poa_status, :factory => :predicted_to_ship
    record_code '40'
    sequence_number { Factory.next :row_number }
  end

  factory :poa_line_item_title_record do
    author { Faker::Name.first_name + ' ' + Faker::Name.last_name }
    association :cdf_binding_code, :factory => :mass_market
    association :poa_order_header, :factory => :poa_order_header
    po_number { poa_order_header.order.number }
    record_code '42'
    sequence_number { Factory.next :row_number }
    title { Faker::Lorem.sentence 5 }
  end

  factory :poa_line_item_pub_record do
    association :poa_order_header, :factory => :poa_order_header
    po_number { poa_order_header.order.number }
    record_code '43'
    sequence_number { Factory.next :row_number }
    total_qty_predicted_to_ship_primary '1'
    publication_release_date { Time.now - 1.month }
    publisher_name { Faker::Lorem.words(3) }
    original_seq_number 0
  end

  factory :poa_order_control_total do
    association :poa_order_header, :factory => :poa_order_header
    record_code '59'
    record_count 5
    sequence_number { Factory.next :row_number }
    total_line_items_in_file 1
    total_units_acknowledged 1
  end

end


