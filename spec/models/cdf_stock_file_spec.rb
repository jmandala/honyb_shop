require 'spec_helper'

describe Cdf::StockImport do

  let(:line_count) { 10000000 }
  let(:inventory_path) { File.join CdfConfig::data_lib_in_root('2012'), 'inventory' }

  before :all do
    GC.enable

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

    @isbns = %w{  
                9780670022953
                9780811218702
                9781556593321
                9781852249229
                9781566892513
                9781933517520
                9781566892438
                9781934200407
                9780375421143
                9780981952079
                9780819571304
                9781933254784
                9781934103210
                9780924047848
                9781934029169
                9781848611283
                9781933517476
                9780887485350
                9789876580168
                9780393932997
                9781555974831
                9781857548402
                9780536419293
                9781555975210
                9781594515521
                9789089790651
                9780061537189
                9780670032181
                9781555974800
                9781934542026
                9780262123112
                9781556593062
                9780521349505
                9781846143533
                9781849011013
                9780674050549
                9780226660615
                9780226673394
                9780393930672
                9780807047156
                9780674018532
                9780262195676
                9780984213382
                9780525423065
              }

  end

  it "should parse the import feed" do
    get_inventory_files.each do |file|
      break if @isbns.size == 0
      
      File.open(path_to(file), 'r') do |f|
        break if @isbns.size == 0
        count = 0
        line_count.times do
          line = f.gets || break
          count += 1
          product = @import_def.parse(line)
          if product[:ean].match /#{@isbns.join('|')}/
            puts "MATCH IN: #{file}"
            puts "EAN: '#{product[:ean]}', #{product[:list_price]} (#{PRODUCT_TYPE[product[:product_type]]}) #{AVAILABILITY[product[:product_availability_code]]} #{STATUS[product[:publisher_status_code]]}"
            @isbns.delete product[:ean]
            break if @isbns.size == 0
          end
        end
      end
      GC.start
    end
    
    if @isbns.size > 0
      puts "MISSING ISBNS:"
      @isbns.each {|i| puts "- #{i}" }
    end
    
  end

  it "should parse these products" do
    lines = []
    lines << '09780670022953              06700229500000243000006200003560000384000000000000000000000000000000000000000037000000000000000000000000000000000000000000000400000040007REG0004000REGIPYYYY    2011100420111004Y99991231N    NYR   REG        REG0002850000000VIK 0872 A  R      N21012339786                  '

    puts @import_def.parse(lines[0]).to_yaml
  end

  it "should retrieve all inventory files" do
    get_inventory_files.size.should > 0
  end


end


def path_full
  File.join inventory_path, 'xao'
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

def get_inventory_files
  files = []
  Dir.foreach(inventory_path) { |f| files << f if File.file?(path_to f) }
  files.sort
end

def path_to(file)
  File.join inventory_path, file
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