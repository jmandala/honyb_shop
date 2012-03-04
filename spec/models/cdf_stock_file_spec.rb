require 'spec_helper'

describe Cdf::StockImport do

  let(:line_count) { 1000000 }

  before :all do
    @import_def = Parser.define do |r|
      r.gtin_prefix 1
      r.ean 13
      r.upc 14
      r.isbn_10 10
      r.la_vergne_on_hand 7
      r.roseburg_on_hand 7
      r.ft_wayne_on_hand 7
      r.chambersburg_on_hand 7
      r.spacer 7
      r.spacer 7
      r.spacer 7
      r.spacer 7
      r.la_vergne_on_order 7
      r.roseburg_on_order 7
      r.ft_wayne_on_order 7
      r.chambersburg_on_order 7
      r.spacer 7
      r.spacer 7
      r.spacer 7
      r.spacer 7
      r.list_price 7
      r.publisher_price 7
      r.spacer 1
      r.discount_level 3
      r.spacer 10
      r.publisher_status_code 2
      r.la_vergne_stock_flag 1
      r.roseburg_stock_flag 1
      r.ft_wayne_stock_flag 1
      r.chambersburg_stock_flag 1
      r.spacer 1
      r.spacer 1
      r.spacer 1
      r.spacer 1
      r.publication_date 8
      r.on_sale_date 8
      r.returnable_indicator 1
      r.return_date 8
      r.print_on_demand_indicator 1
      r.spacer 4
      r.backorder_only_indicator 1
      r.media_mail_indicator 1
      r.product_type 1
      r.imprintable_indicator 1
      r.indexable_indicator 1
      r.spacer 15
      r.weight 6
      r.spacer 11
      r.ingram_publisher_number 4
      r.spacer 5
      r.restricted_code 1
      r.discount_category_code 5
      r.spacer 7
      r.product_availability_code 2
      r.ingram_title_code 9
      r.spacer 19
    end
  end

  it "should parse the import feed" do
    File.open(path_full, 'r') do |f|
      line_count.times do
        line = f.gets || break
        product = @import_def.parse(line)
          if product[:ean].starts_with? '978'
            puts "EAN: #{product[:ean]}, #{product[:list_price]} (#{PRODUCT_TYPE[product[:product_type]]}) #{AVAILABILITY[product[:product_availability_code]]} #{STATUS[product[:publisher_status_code]]}"
          end
      end
    end

  end

end


def path_full
  File.join CdfConfig::data_lib_in_root('2012'), 'stockv2@ingram.dat'
end

def path_small
  File.join CdfConfig::data_lib_in_root('2012'), 'stockv2@ingram-small.dat'
end

def get_stock(count=1)
  lines = []

  File.open(path_full, 'r') do |f|
    count.times do
      line = f.gets || break
      lines << line
    end
  end
  lines
end

def write_small_file(path_small, count=1)
  File.open(path_small, 'w') { |f| f.write(get_stock(count).join) }
end

def init_small_file
  write_small_file(get_stock, path_small)
end

PRODUCT_TYPE = {'R' => 'Hardcover - also called cloth, retail trade, or trade',
                'Q' => 'Quality Paper - also called trade paper',
                'P' => 'Mass Market Paperbacks - always rack size',
                'T' => 'Calendars, blank books, and other book-like sideline items',
                'W' => 'Audio',
                'S' => 'Computer Software or Multimedia',
                'K' => 'Video',
                'X' => 'Music Titles',
                'M' => 'Gifts, Cards, and other non-book sideline items',
                'N' => 'Musicland Bargain Books',
                'U' => 'Other Spring Arbor'}

AVAILABILITY = {
    '10' => "Not yet available",
    '20' => "Available",
    '21' => "In stock",
    '22' => "To order",
    '31' => "Out of stock",
    '40' => "Not available"
}

STATUS = {
    'AB' => "Canceled",
    'CS' => "Availability Uncertain",
    'EX' => "No longer stocked by Ingram",
    'IP' => "In print and available",
    'NY' => "Not yet published",
    'OI' => "Out of stock indefinitely",
    'OP' => "Out of print",
    'PP' => "Postponed indefinitely",
    'RF' => "Referred to another supplier",
    'RM' => "Remaindered",
    'TP' => "Temporarily out of stock because publisher cannot supply",
    'WS' => "Withdrawn from Sale"
}

class Parser

  attr_accessor :columns, :sizes

  def initialize
    @columns = []
    @sizes = []
  end

  def method_missing(method, *args)
    @columns << method
    @sizes << args[0]
  end

  def unpack_code
    code = ""
    @sizes.each { |s| code << "a#{s}" }
    code
  end

  def parse(input)
    records = []
    if input.respond_to? :each
      input.each { |i| records << as_record(i.unpack unpack_code) }
    else
      return as_record(input.unpack unpack_code)
    end

    records
  end

  def as_record(values)
    record = {}
    values.each_with_index do |v, i|
      column_name = @columns[i]
      record["#{column_name}".to_sym] = v
    end
    record
  end

  def self.define
    parser = new
    yield(parser)
    parser
  end


end