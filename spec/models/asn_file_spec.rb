require_relative '../spec_helper'

describe AsnFile do

  it_should_behave_like "an importable file", AsnFile, 200, 'PBS' do

    let(:outgoing_file) { '05503677.PBS' }
    let(:incoming_file) { 'T5503677.PBS' }

    let(:outgoing_contents) do
      "CR20N2730   000000024.0                                                                                                                                                                                 
ORR374103387                    00000019990000000000000000000000000000000000000000001000000000299900000100   000120110812                                                                               
ODR374103387            C 01705          0373200005037320000500001     00001001ZTESTTRACKCI017050000   SCAC 1              000049900003241         TESTSSLCI01705000001000000020129780373200009         
ORR674657678                    00000039980000000000000000000000000000000000000000001000000000499800000200   000120110812                                                                               
ODR674657678            C 01706          0373200005037320000500001     00001001ZTESTTRACKCI017060000   SCAC 2              000049900003242         TESTSSLCI01706000001000000020129780373200009         
"
    end

    let(:test_contents) do
      "CR20N2730   000000024.0                                                                                                                                                                                 
ORR374103387                    00000019990000000000000000000000000000000000000000001000000000299900000100   000120110812                                                                               
ODR374103387            C 01705          0373200005037320000500001     00001001ZTESTTRACKCI017050000   SCAC 1              000049900003241         TESTSSLCI01705000001000000020129780373200009         
ORR674657678                    00000039980000000000000000000000000000000000000000001000000000499800000200   000120110812                                                                               
ODR674657678            C 01706          0373200005037320000500001     00001001ZTESTTRACKCI017060000   SCAC 2              000049900003242         TESTSSLCI01706000001000000020129780373200009         
"
    end

    let(:order_number_1) { 'R374103387' }
    let(:order_number_2) { 'R674657678' }

    let(:product_1) { @product_1 = Factory(:product, :sku => '978-0-37320-000-9', :price => 10, :name => 'test product') }
    let(:product_2) { @product_2 = Factory(:product, :sku => '978-0-37320-800-5', :price => 10, :name => 'test product 2') }

    
    let(:line_item_1) { @line_item_1 = Factory(:line_item, :quantity => 2, :variant => @product_1.master, :price => 10, :order => @order_1) }
    let(:line_item_2) { @line_item_2 = Factory(:line_item, :quantity => 2, :variant => @product_2.master, :price => 10, :order => @order_1) }

    let(:line_item_3) { @line_item_3 = Factory(:line_item, :quantity => 2, :variant => @product_1.master, :price => 10, :order => @order_2) }
    let(:line_item_4) { @line_item_4 = Factory(:line_item, :quantity => 2, :variant => @product_2.master, :price => 10, :order => @order_2) }


    let(:validations) do
      [:should_import_asn_shipment_detail_record,
       :should_import_asn_shipment_record,
       :should_import_asn_file_data,
       :should_reference_shipment
      ]
    end
  end
end

def should_reference_shipment(parsed, asn_file)
  parsed[:asn_shipment_detail].each do |record|
    db_record = AsnShipmentDetail.find_self asn_file, record[:__LINE_NUMBER__]
    
    db_record.shipment.should_not == nil
  end
end

def should_import_asn_shipment_detail_record(parsed, asn_file)

  parsed[:asn_shipment_detail].each do |record|
    db_record = AsnShipmentDetail.find_self asn_file, record[:__LINE_NUMBER__]
    db_record.should_not == nil
    db_record.asn_file.should == asn_file
    db_record.order.should_not == nil
    db_record.record_code.should == 'OD'
    db_record.order.should == Order.find_by_number(record[:client_order_id].strip)

    db_record.asn_shipment.should_not == nil
    
    [:ingram_order_entry_number,
     :isbn_10_ordered,
     :isbn_10_shipped,
     :tracking,
     :standard_carrier_address_code,
     :ssl,
     :isbn_13].each { |field| ImportFileHelper.should_match_text(db_record, record, field) }

    [:ingram_item_list_price,
     :net_discounted_price].each { |field| ImportFileHelper.should_match_money(db_record, record, field) }

    [:quantity_canceled,
     :quantity_predicted,
     :quantity_slashed,
     :quantity_shipped].each { |field| ImportFileHelper.should_match_i(db_record, record, field) }

    db_record.weight.should == BigDecimal.new((record[:weight].to_f / 100).to_s, 0)

    db_record.asn_shipping_method_code.should == AsnShippingMethodCode.find_by_code(record[:shipping_method_or_slash_reason_code])

    db_record.asn_order_status.code.should == record[:item_detail_status_code]

    db_record.dc_code.should_not == nil
    first = record[:shipping_warehouse_code].match(/./).to_s
    codes = DcCode.where("asn_dc_code LIKE ?", "#{first}%")
    db_record.dc_code.should == codes.first

    DcCode.find_by_asn_dc_code(record[:shipping_warehouse_code]).to_yaml

    db_record.line_item = LineItem.find_by_id(record[:line_item_id_number])
    
    
    db_record.shipment.state.should == 'shipped'
  end
end

def should_import_asn_shipment_record(parsed, asn_file)
  parsed[:asn_shipment].each do |record|
    db_record = AsnShipment.find_self asn_file, record[:__LINE_NUMBER__]
    db_record.should_not == nil
    db_record.asn_file.should == asn_file
    db_record.order.should_not == nil
    db_record.record_code.should == 'OR'
    db_record.order.should == Order.find_by_number(record[:client_order_id].strip)
    db_record.asn_order_status.code.should == record[:order_status_code]
    db_record.asn_shipment_details.should_not == nil
    db_record.asn_shipment_details.count.should > 0

    [:consumer_po_number].each { |field| ImportFileHelper.should_match_text(db_record, record, field) }

    [:order_subtotal,
     :order_discount_amount,
     :order_total,
     :freight_charge].each { |field| ImportFileHelper.should_match_money(db_record, record, field) }

    db_record.shipping_and_handling.should == BigDecimal.new((record[:shipping_and_handling].to_f / 10000).to_s, 0)
  end
end

def should_import_asn_file_data(parsed, asn_file)
  all = parsed[:header]
  all.should_not == nil
  all.size.should == 1
  parsed = all.first

  db_record = asn_file
  db_record.record_code.should == 'CR'
  db_record.created_at.should_not == nil

  [:company_account_id_number, :file_version_number, :record_code].each do |field|
    ImportFileHelper.should_match_text(db_record, parsed, field)
  end

  [:total_order_count].each { |field| ImportFileHelper.should_match_i(db_record, parsed, field) }

  db_record.file_version_number.should == '4.0'
  db_record.parent.should == nil
  db_record.versions.should == []
end

