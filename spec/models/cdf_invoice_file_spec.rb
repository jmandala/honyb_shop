require 'spec_helper'

describe CdfInvoiceFile do
  
  it_should_behave_like "an importable file", CdfInvoiceFile, 80, 'BIN' do
    
    let(:create_order_1) { %Q[Cdf::OrderBuilder.completed_test_order(:ean => product_1.sku, :order_number => 'R483688864')] }
    let(:create_order_2) { %Q[Cdf::OrderBuilder.completed_test_order(:ean => product_1.sku, :order_number => 'R746668282')] }

    let(:outgoing_file) { '05536017.BIN' }
    let(:incoming_file) { 'T5536017.BIN' }

    let(:binary_file_name) { nil }

    let(:outgoing_contents) do
      %q[%Q[0100001169797800000INGRAM BK CO 110822INVOICE COMMUNICATIONS                    
150000210003868                   20N2730     254410500020110822                
450000310003868                   0373200005 000010000499 0035 0000032420110822 
460000410003868                                              9780373200009      
48000051000386820110822HQPB FAMOUS FIRS00000#{@order_1.number.ljust_trim(22)}#{@order_1.line_items[0].id.ljust_trim(10)}0000
4900006100038681ZTESTTRACKCI018370000   0000032400000000000000000000000000000324
450000710003868                   0373200005 000010000499 0035 0000032420110822 
460000810003868                                              9780373200009      
48000091000386820110822HQPB FAMOUS FIRS00000#{@order_2.number.ljust_trim(22)}#{@order_2.line_items[0].id.ljust_trim(10)}0000
4900010100038681ZTESTTRACKCI018360000   0000032400000000000000000000000000000324
550001110003868     0000900002000002TESTCI0001       0000000                    
570001210003868     000000648      00000000000000000000000000          000000648
150000110003869                   20N2730            00020110822                
450000210003869                   555887564X 000010000000 0000 0000000020110822 
460000310003869                                              9785558875645      
48000041000386920110822 ORDER CHARGE   00000#{@order_1.number.ljust_trim(22)}          0000
450000510003869                   5558875666 000010000065 0000 0000006520110822 
460000610003869                                              9785558875669      
48000071000386920110822 PER PIECE CHARG00000#{@order_1.number.ljust_trim(22)}          0000
4900008100038691ZTESTTRACKCI018370000   0000000000000100000650000000000000000066
450000910003869                   555887564X 000010000000 0000 0000000020110822 
460001010003869                                              9785558875645      
48000111000386920110822 ORDER CHARGE   00000#{@order_2.number.ljust_trim(22)}          0000
450001210003869                   5558875666 000010000065 0000 0000006520110822 
460001310003869                                              9785558875669      
48000141000386920110822 PER PIECE CHARG00000#{@order_2.number.ljust_trim(22)}          0000
4900015100038691ZTESTTRACKCI018370000   0000000000000200000650000000000000000067
550001610003869     0001500004000004TESTCI0001       0000000                    
570001710003869     000000000      00000030000130000000000000          000000133
95000180000000000006000020000000006                                             ]]
    end

    let(:test_contents) do
      outgoing_contents
    end

    let(:product_1) { @product_1 = Factory(:product, :sku => '978-0-37320-000-9', :price => 10, :name => 'test product') }
    let(:product_2) { @product_2 = Factory(:product, :sku => '978-0-37320-000-2', :price => 10, :name => 'test product 2') }

    let(:line_item_1) { @line_item_1 = Factory(:line_item, :quantity => 2, :variant => @product_1.master, :price => 10, :order => @order_1) }
    let(:line_item_2) { @line_item_2 = Factory(:line_item, :quantity => 2, :variant => @product_2.master, :price => 10, :order => @order_1) }

    let(:line_item_3) { @line_item_3 = Factory(:line_item, :quantity => 2, :variant => @product_1.master, :price => 10, :order => @order_2) }
    let(:line_item_4) { @line_item_4 = Factory(:line_item, :quantity => 2, :variant => @product_2.master, :price => 10, :order => @order_2) }


    let(:validations) do
      [
          :should_import_cdf_invoice_file_data,
          :should_import_cdf_invoice_header,
          :should_import_cdf_invoice_isbn_detail,
          :should_import_cdf_invoice_ean_detail,
          :should_import_cdf_invoice_freight_and_fees,
          :should_import_cdf_invoice_detail_totals,
          :should_import_cdf_invoice_totals,
          :should_import_cdf_invoice_trailers,
          :should_import_cdf_invoice_file_trailers
      ]
    end
  end

end

def dump_fees(f)
  puts "FREIGHT & FEES: #{f.net_price} (net), #{f.shipping} (shipping), #{f.handling} (handling), #{f.gift_wrap} (gift wrap), #{f.amount_due} (amount due), #{f.tracking_number} (tracking)"
  [:invoice_number, :line_number, :cdf_invoice_header_id, :cdf_invoice_detail_total_id, :id].each do |k|
    puts "#{k} = #{f.send(k)}"
  end
  puts "\n"
end

def should_import_cdf_invoice_trailers(parsed, cdf_invoice_file)
  ImportFileHelper.should_match_count(CdfInvoiceTrailer, 2)

  parsed[:cdf_invoice_trailer].each do |record|
    db_record = CdfInvoiceTrailer.find_self cdf_invoice_file, record[:__LINE_NUMBER__]
    db_record.should_not == nil
    db_record.cdf_invoice_file.should == cdf_invoice_file
    db_record.record_code.should == '57'

    [:total_invoice,
     :total_gift_wrap,
     :total_handling,
     :total_shipping,
     :total_net_price
    ].each { |field| ImportFileHelper.should_match_money(db_record, record, field) }

    db_record.cdf_invoice_header.should_not == nil
  end

end

def should_import_cdf_invoice_file_trailers(parsed, cdf_invoice_file)
  ImportFileHelper.should_match_count(CdfInvoiceFileTrailer, 1)

  parsed[:cdf_invoice_file_trailer].each do |record|
    db_record = CdfInvoiceFileTrailer.find_self! cdf_invoice_file, record[:__LINE_NUMBER__]
    db_record.should_not == nil
    db_record.cdf_invoice_file.should == cdf_invoice_file
    db_record.record_code.should == '95'

    [:total_titles,
     :total_invoices,
     :total_units
    ].each { |field| ImportFileHelper.should_match_i(db_record, record, field) }
  end

end

def should_import_cdf_invoice_totals(parsed, cdf_invoice_file)
  ImportFileHelper.should_match_count(CdfInvoiceTotal, 2)

  parsed[:cdf_invoice_total].each do |record|
    db_record = CdfInvoiceTotal.find_self cdf_invoice_file, record[:__LINE_NUMBER__]
    db_record.should_not == nil
    db_record.cdf_invoice_file.should == cdf_invoice_file
    db_record.record_code.should == '55'

    [:bill_of_lading_number].each { |field| ImportFileHelper.should_match_text(db_record, record, field) }
    [:total_invoice_weight,
     :total_number_of_units,
     :number_of_titles,
     :invoice_record_count
    ].each { |field| ImportFileHelper.should_match_i(db_record, record, field) }

  end

end

def should_import_cdf_invoice_detail_totals(parsed, cdf_invoice_file)
  LineItem.all.each { |li| li.cdf_invoice_detail_totals.count > 0 }

  Order.all.each { |i| i.cdf_invoice_detail_totals.count.should > 0 }

  ImportFileHelper.should_match_count(CdfInvoiceDetailTotal, 6)
  parsed[:cdf_invoice_detail_total].each do |record|
    db_record = CdfInvoiceDetailTotal.find_self cdf_invoice_file, record[:__LINE_NUMBER__]
    db_record.should_not == nil
    db_record.cdf_invoice_file.should == cdf_invoice_file
    db_record.record_code.should == '48'

    db_record.order.should_not == nil
    db_record.order.should == Order.find_by_number!(record[:client_order_id].strip)

    db_record.line_item_id.should_not == nil unless record[:line_item_id_number].blank?

    db_record.cdf_invoice_isbn_detail.should_not == nil
    db_record.cdf_invoice_ean_detail.should_not == nil
  end
end


def should_import_cdf_invoice_freight_and_fees(parsed, cdf_invoice_file)
  Order.all.each { |i| i.cdf_invoice_freight_and_fees.count.should > 0 }

  ImportFileHelper.should_match_count(CdfInvoiceFreightAndFee, 4)

  parsed[:cdf_invoice_freight_and_fee].each do |record|
    db_record = CdfInvoiceFreightAndFee.find_self cdf_invoice_file, record[:__LINE_NUMBER__]
    db_record.should_not == nil
    db_record.cdf_invoice_file.should == cdf_invoice_file
    db_record.record_code.should == '49'

    [:tracking_number].each { |field| ImportFileHelper.should_match_text(db_record, record, field) }

    [:net_price,
     :shipping,
     :handling,
     :gift_wrap,
     :amount_due].each { |field| ImportFileHelper.should_match_money(db_record, record, field) }

    db_record.cdf_invoice_header.should_not == nil
    db_record.cdf_invoice_detail_total.should_not == nil
  end
end

def should_import_cdf_invoice_ean_detail(parsed, cdf_invoice_file)
  ImportFileHelper.should_match_count(CdfInvoiceEanDetail, 6)

  parsed[:cdf_invoice_ean_detail].each do |record|
    db_record = CdfInvoiceEanDetail.find_self cdf_invoice_file, record[:__LINE_NUMBER__]
    db_record.should_not == nil
    db_record.cdf_invoice_file.should == cdf_invoice_file
    db_record.record_code.should == '46'

    [:ean_shipped].each { |field| ImportFileHelper.should_match_text(db_record, record, field) }

    [:invoice_number].each { |field| ImportFileHelper.should_match_i(db_record, record, field) }

  end
end

def should_import_cdf_invoice_isbn_detail(parsed, cdf_invoice_file)
  ImportFileHelper.should_match_count(CdfInvoiceIsbnDetail, 6)

  parsed[:cdf_invoice_isbn_detail].each do |record|
    db_record = CdfInvoiceIsbnDetail.find_self cdf_invoice_file, record[:__LINE_NUMBER__]
    db_record.should_not == nil
    db_record.cdf_invoice_file.should == cdf_invoice_file
    db_record.record_code.should == '45'

    [:isbn_10_shipped].each { |field| ImportFileHelper.should_match_text(db_record, record, field) }

    [:ingram_list_price,
     :discount,
     :net_price].each { |field| ImportFileHelper.should_match_money(db_record, record, field) }

    [:invoice_number,
     :quantity_shipped].each { |field| ImportFileHelper.should_match_i(db_record, record, field) }

    [:metered_date].each { |field| ImportFileHelper.should_match_date(db_record, record, field, "%Y%m%d") }

  end
end

def should_import_cdf_invoice_header(parsed, cdf_invoice_file)
  ImportFileHelper.should_match_count(CdfInvoiceHeader, 2)

  parsed[:cdf_invoice_header].each do |record|
    db_record = CdfInvoiceHeader.find_self cdf_invoice_file, record[:__LINE_NUMBER__]
    db_record.should_not == nil
    db_record.cdf_invoice_file.should == cdf_invoice_file
    db_record.record_code.should == '15'

    [:sequence_number].each { |field| ImportFileHelper.should_match_text(db_record, record, field) }
    [:invoice_number, :warehouse_san, :company_account_id_number].each do |field|
      ImportFileHelper.should_match_i(db_record, record, field)
    end

    [:invoice_date].each { |field| ImportFileHelper.should_match_date(db_record, record, field, "%Y%m%d") }

    db_record.cdf_invoice_detail_totals.should_not == nil
    db_record.cdf_invoice_freight_and_fees.should_not == nil
    db_record.cdf_invoice_trailer.should_not == nil
  end
end

def should_import_cdf_invoice_file_data(parsed, cdf_invoice_file)
  all = parsed[:header]
  all.should_not == nil
  all.size.should == 1
  parsed = all.first

  db_record = cdf_invoice_file
  db_record.record_code.should == '01'
  db_record.created_at.should_not == nil

  [:record_code,
   :sequence_number,
   :file_source,
   :ingram_file_name].each do |field|
    ImportFileHelper.should_match_text(db_record, parsed, field)
  end

  [:ingram_san].each { |field| ImportFileHelper.should_match_i(db_record, parsed, field) }
  [:creation_date].each { |field| ImportFileHelper.should_match_date(db_record, parsed, field) }
  db_record.file_name.should == outgoing_file
  db_record.versions.should == []
  db_record.parent.should == nil

  db_record.orders.should_not == nil
  db_record.orders.count.should == 2
  db_record.orders.each { |o| o.class.should == Order }
end
