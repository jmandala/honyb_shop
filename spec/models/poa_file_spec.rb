require_relative '../spec_helper'

MAX_POA_VENDOR_RECORDS = 6

describe PoaFile do

  it_should_behave_like "an importable file", PoaFile, 80, 'fbc' do

    let(:outgoing_file) { '110809180859.fbc' }
    let(:incoming_file) { 't10809180859.fbc' }
    
    let(:po_file_name) { outgoing_file.gsub(/fbc/, 'fbo') }

    let(:order_number_1) { 'R554266337' }
    let(:order_number_2) { 'R543255800' }

    let(:order_1) { Cdf::OrderBuilder.completed_test_order(:ean => %w(9780373200009 978037352805), :order_number => 'R543255800') }
    let(:order_2) { Cdf::OrderBuilder.completed_test_order(:ean => %w(9780373200009 978037352805), :order_number => 'R554266337') }
    
    
    
    
    let(:outgoing_contents) do
%Q[02000011697978     INGRAM       110810RUYFU110809180859.FBO F030000000     1    
1100002             #{order_1.number.ljust_trim(22)}20N273016979780110810110810110810     
2100003#{order_1.number.ljust_trim(22)}THANK YOU FOR YOUR ORDER.  IF YOU REQUIRE ASSISTAN 
2100004#{order_1.number.ljust_trim(22)}CE, PLEASE CONTACT OURELECTRONIC ORDERING DEPARTME 
2100005#{order_1.number.ljust_trim(22)}NT AT 1-800-234-6737 OR VIA EMAIL AT        FLASHB 
2100006#{order_1.number.ljust_trim(22)}ACK@INGRAMBOOK.COM.  TO CANCEL AN ORDER, PLEASE SP 
2100007#{order_1.number.ljust_trim(22)}EAK WITH AN     ELECTRONIC ORDERING REPRESENTATIVE 
2100008#{order_1.number.ljust_trim(22)} AT 1-800-234-6737.                                
4000009#{order_1.number.ljust_trim(22)}#{order_1.line_items[0].id.ljust_trim(10)}            9780373200009       00100100C
4100010#{order_1.number.ljust_trim(22)}000 000000{ 0000 0000 0000 0000 0000 0000 0000     
4200011#{order_1.number.ljust_trim(22)}HQPB FAMOUS FIRSTS MATCHMAKERSMACOMBER DEBBIE     M
4300012#{order_1.number.ljust_trim(22)}HQPB                030900019350000000010000000    
4400013#{order_1.number.ljust_trim(22)}                    00004.99EN00003.240000001      
4500014#{order_1.number.ljust_trim(22)}2                                                  
4000015#{order_1.number.ljust_trim(22)}#{order_1.line_items[1].id.ljust_trim(10)}            978037352805        00100005C
4100016#{order_1.number.ljust_trim(22)}000         0000 0000 0000 0000 0000 0000 0000     
4100017#{order_1.number.ljust_trim(22)}000 000000  0000 0000 0000 0000 0000 0000 0000     
4200018#{order_1.number.ljust_trim(22)}                                                   
4300019#{order_1.number.ljust_trim(22)}                        00022000000000000000000    
4400020#{order_1.number.ljust_trim(22)}                    00000.00EN00000.000000001      
4500021#{order_1.number.ljust_trim(22)}5                                                  
5900022#{order_1.number.ljust_trim(22)}000200000000002000000000100000000040000000000000001
1100023             #{order_2.number.ljust_trim(22)}20N273016979780110810110810110810     
2100024#{order_2.number.ljust_trim(22)}THANK YOU FOR YOUR ORDER.  IF YOU REQUIRE ASSISTAN 
2100025#{order_2.number.ljust_trim(22)}CE, PLEASE CONTACT OURELECTRONIC ORDERING DEPARTME 
2100026#{order_2.number.ljust_trim(22)}NT AT 1-800-234-6737 OR VIA EMAIL AT        FLASHB 
2100027#{order_2.number.ljust_trim(22)}ACK@INGRAMBOOK.COM.  TO CANCEL AN ORDER, PLEASE SP 
2100028#{order_2.number.ljust_trim(22)}EAK WITH AN     ELECTRONIC ORDERING REPRESENTATIVE 
2100029#{order_2.number.ljust_trim(22)} AT 1-800-234-6737.                                
4000030#{order_2.number.ljust_trim(22)}#{order_2.line_items[0].id.ljust_trim(10)}            9780373200009       00100100C
4100031#{order_2.number.ljust_trim(22)}000 000000{ 0000 0000 0000 0000 0000 0000 0000     
4200032#{order_2.number.ljust_trim(22)}HQPB FAMOUS FIRSTS MATCHMAKERSMACOMBER DEBBIE     M
4300033#{order_2.number.ljust_trim(22)}HQPB                030900043350000000010000000    
4400034#{order_2.number.ljust_trim(22)}                    00004.99EN00003.240000001      
4500035#{order_2.number.ljust_trim(22)}3                                                  
4000036#{order_2.number.ljust_trim(22)}#{order_2.line_items[1].id.ljust_trim(10)}            978037352805        00100005C
4100037#{order_2.number.ljust_trim(22)}000         0000 0000 0000 0000 0000 0000 0000     
4100038#{order_2.number.ljust_trim(22)}000 000000  0000 0000 0000 0000 0000 0000 0000     
4200039#{order_2.number.ljust_trim(22)}                                                   
4300040#{order_2.number.ljust_trim(22)}                        00046000000000000000000    
4400041#{order_2.number.ljust_trim(22)}                    00000.00EN00000.000000001      
4500042#{order_2.number.ljust_trim(22)}6                                                  
5900043#{order_2.number.ljust_trim(22)}000200000000002000000000100000000040000000000000001
9100044000000000000400002000000000200001000020001200000000260000200001          ]      
    end

    let(:test_contents) do
      outgoing_contents
    end


    let(:product_1) { @product_1 = Factory(:product, :sku => '978-0-37320-000-9', :price => 10, :name => 'test product') }
    let(:product_2) { @product_2 = Factory(:product, :sku => '978-0-37320-800-5', :price => 10, :name => 'test product 2') }

    let(:line_item_1) { @line_item_1 = Factory(:line_item, :quantity => 2, :variant => @product_1.master, :price => 10, :order => @order_1) }
    let(:line_item_2) { @line_item_2 = Factory(:line_item, :quantity => 2, :variant => @product_2.master, :price => 10, :order => @order_1) }

    let(:line_item_3) { @line_item_3 = Factory(:line_item, :quantity => 2, :variant => @product_1.master, :price => 10, :order => @order_2) }
    let(:line_item_4) { @line_item_4 = Factory(:line_item, :quantity => 2, :variant => @product_2.master, :price => 10, :order => @order_2) }

    let(:validations) do
      [:should_import_poa_line_item_pub_record,
       :should_import_poa_file_data,
       :should_import_poa_order_header,
       :should_import_poa_line_items,
       :should_import_poa_additional_details,
       :should_import_poa_file_control_total,
       :should_import_poa_order_control_total,
       :should_import_poa_line_item_pub_record,
       :should_import_poa_line_item_title_record,
       :should_not_have_poa_ship_to_name,
       :should_not_have_poa_address_lines,
       :should_not_have_poa_city_state_zip,
       :should_import_poa_item_number_price_record
      ]
    end
  end

  before(:all) do
    FactoryGirl.create(:chambersburg)
    Order.all.each &:destroy!
  end

  after(:all) do
    Order.all.each &:destroy!
  end

  before(:each) do
    PoaFile.all.each &:destroy
  end


  context "when importing an exception file" do
    before(:each) do
      @error_file_name = 'error_file.fbc'
      @error_file = PoaFile.create(:file_name => @error_file_name)
      @error_file.write_data 'NO MAINFRAME'
      @error_file.save!
    end

    it "should log an error message" do
      result = @error_file.import
      result.class.should == CdfImportExceptionLog
    end
  end
end

def should_import_poa_item_number_price_record(parsed, poa_file)
  parsed = parsed[:poa_item_number_price_records]
  parsed.should == nil
end


def should_not_have_poa_city_state_zip(parsed, poa_file)
  parsed[:poa_city_state_zip].should == nil
  poa_file.poa_order_headers.first.poa_city_state_zip.should == nil
end


def should_not_have_poa_address_lines(parsed, poa_file)
  parsed[:poa_address_lines].should == nil
  poa_file.poa_order_headers.first.poa_address_lines.should == []
end

def should_not_have_poa_ship_to_name(parsed, poa_file)
  parsed[:poa_ship_to_name].should == nil
  poa_file.poa_order_headers.first.poa_ship_to_name.should == nil
end

def should_match_text(object, record, field)
  object.read_attribute(field).should == record[field].strip
end

def should_match_i(object, record, field)
  object.send(field).should == record[field].strip.to_i
end

def should_match_date(object, record, field, fmt="%y%m%d")
  import_value = record[field]
  object_value = object.send(field)

  if import_value.to_i == 0
    return object_value.should == nil
  end

  object_value.strftime(fmt).should == Time.strptime(import_value, fmt).strftime(fmt)
end

def should_import_poa_order_header(parsed, poa_file)
  all = parsed[:poa_order_header]
  all.should_not == nil
  all.size.should == 2
  poa_file.poa_order_headers.count.should == 2

  all.each_with_index do |record, i|
    db_record = poa_file.poa_order_headers[i]
    db_record.poa_file.should == poa_file
    db_record.po_status.code.should == record[:po_status].to_i
    db_record.order.should_not == nil
    db_record.order.number.should_not == nil
    db_record.order.number.should == record[:po_number].strip

    db_record.poa_vendor_records.count.should == MAX_POA_VENDOR_RECORDS
    db_record.poa_ship_to_name.should == nil
    db_record.poa_address_lines.should == []
    db_record.poa_city_state_zip.should == nil
    db_record.poa_line_items.count.should == 2


    db_record.poa_additional_details.count.should > 0
    db_record.poa_line_item_title_records.count.should == 2
    db_record.poa_line_item_pub_records.count.should == 2
    db_record.poa_item_number_price_records.count.should == 2

    db_record.poa_order_control_total.should_not == nil

    [:icg_san,
     :icg_ship_to_account_number,
     :po_number,
     :record_code,
     :sequence_number,
     :toc
    ].each { |k| should_match_text(db_record, record, k) }

    [:acknowledgement_date, :po_cancellation_date, :po_date].each { |k| should_match_date(db_record, record, k) }
  end
end

def should_import_poa_additional_details(parsed, poa_file)
  parsed[:poa_additional_detail].each do |record|
    db_record = PoaAdditionalDetail.find_self poa_file, record[:sequence_number]
    db_record.should_not == nil

    [:po_number,
     :record_code,
     :sequence_number,
     :dc_inventory_information].each { |k| should_match_text(db_record, record, k) }

    if !record[:availability_date].nil?
      [:availability_date].each { |k| should_match_date(db_record, record, k) }
    end

    db_record.nearest_poa_line_item.should == db_record.poa_line_item
    db_record.poa_line_item.should_not == nil
  end
end

def should_import_poa_line_item_title_record(parsed, poa_file)
  parsed[:poa_line_item_title_record].each do |record|
    db_record = PoaLineItemTitleRecord.find_self poa_file, record[:sequence_number]

    [:title,
     :author,
     :record_code,
     :sequence_number].each { |k| should_match_text(db_record, record, k) }

    record[:binding_code].should == db_record.cdf_binding_code.code
  end
end


def should_import_poa_line_items(parsed, poa_file=nil)
  parsed[:poa_line_item].each do |record|
    db_record = PoaLineItem.find_by_line_item_po_number(record[:line_item_po_number].strip)
    db_record.should_not == nil

    [:po_number,
     :record_code,
     :sequence_number].each { |k| should_match_text(db_record, record, k) }

    record[:dc_code].should_not == nil
    record[:dc_code].should == db_record.dc_code.poa_dc_code
    record[:poa_status].should_not == nil
    record[:poa_status].should == db_record.poa_status.code
    db_record.order.should_not == nil
    record[:po_number].strip.should == db_record.order.number

    db_record.line_item_id.should_not == nil
  end
end


def should_import_poa_file_data(parsed, poa_file)
  all = parsed[:header]
  all.should_not == nil
  all.size.should == 1
  parsed = all.first

  db_record = poa_file
  db_record.created_at.should_not == nil
  db_record.destination_san.should_not == nil

  [:electronic_control_unit,
   :destination_san,
   :file_source_name,
   :format_version,
   :record_code,
   :sequence_number
  ].each { |field| should_match_text(db_record, parsed, field) }

  should_match_date(db_record, parsed, :poa_creation_date)

  db_record.file_name.should == outgoing_file
  db_record.parent.should == nil
  db_record.versions.should == []
  db_record.po_file.should == PoFile.find_by_file_name!(po_file_name)
end

def should_import_poa_file_control_total(parsed, poa_file)
  parsed[:poa_file_control_total].each do |record|

    db_record = PoaFileControlTotal.find_by_poa_file_id(poa_file.id)

    [:record_code, :sequence_number].each { |k| should_match_text(db_record, record, k) }
    [:record_count_01,
     :record_count_02,
     :record_count_03,
     :record_count_04,
     :record_count_05,
     :record_count_06,
     :total_line_items_in_file,
     :total_pos_acknowledged,
     :total_units_acknowledged].each { |k| should_match_i(db_record, record, k) }
  end
end


def should_import_poa_order_control_total(parsed, poa_file)
  parsed[:poa_order_control_total].each do |record|
    db_record = PoaOrderControlTotal.find_self(poa_file, record[:sequence_number])

    [:record_code,
     :sequence_number].each { |k| should_match_text(db_record, record, k) }
    [:total_line_items_in_file,
     :total_units_acknowledged,].each { |k| should_match_i(db_record, record, k) }

    db_record.total_line_items_in_file.should == db_record.poa_order_header.poa_line_items.count
  end
end


def should_import_poa_line_item_pub_record(parsed, poa_file)
  parsed[:poa_line_item_pub_record].each do |record|
    db_record = PoaLineItemPubRecord.find_self(poa_file, record[:sequence_number])

    [:publisher_name,
     :original_seq_number,
     :total_qty_predicted_to_ship_primary,
     :record_code,
     :sequence_number].each { |k| should_match_text(db_record, record, k) }

    if record[:publication_release_date].empty?
      db_record.publication_release_date.should == nil
    else
      db_record.publication_release_date.strftime("%m%y").should == record[:publication_release_date]
    end
  end
end
