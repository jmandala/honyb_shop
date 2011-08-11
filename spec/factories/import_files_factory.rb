FactoryGirl.define do

  factory :poa_file do
    file_name "#{Time.now.strftime("%y%m%d%H%M%S")}.fbc"
  end

  factory :poa_order_header do
    record_code '11'
    association :poa_file, :factory => :poa_file
    association :order, :factory => :order
    po_number { order.number }
    sequence_number '00002'
    acknowledgement_date Time.now
    icg_san '1697978'
    icg_ship_to_account_number Spree::Config.get(:cdf_ship_to_account_number)
    po_cancellation_date (Time.new + 3.months)
    #po_date { order.updated_at }
    toc 'C123456789012'
  end

  factory :poa_additional_detail do
    availability_date Time.now
    association :poa_order_header, :factory => :poa_order_header
    po_number { poa_order_header.order.number }
  end
end


