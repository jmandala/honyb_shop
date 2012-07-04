Product.class_eval do

  PRODUCT_TYPES =  {'R' => { :id => :hardcover, :text => "Hardcover" },
                    'Q' => { :id => :quality, :text => "Quality Paper" },
                    'P' => { :id => :paperback, :text => "Mass Market Paperbacks" },
                    'T' => { :id => :calendar, :text => "Calendar" },
                    'W' => { :id => :audio, :text => "Audio" },
                    'S' => { :id => :computer, :text => "Computer Software or Multimedia" },
                    'K' => { :id => :video, :text => "Video" },
                    'X' => { :id => :music, :text => "Music Titles" },
                    'M' => { :id => :gifts, :text => "Gifts, Cards, and other non-book sideline items" },
                    'N' => { :id => :bargain, :text => "Musicland Bargain Books" },
                    'U' => { :id => :other, :text => "Other Spring Arbor" } }

  AVAILABILITY_STATUS = {'10' => { :id => :not_yet, :text => "Not Yet Available" },
                         '20' => { :id => :available, :text => "Available" },
                         '21' => { :id => :in_stock, :text => "In stock" },
                         '22' => { :id => :to_order, :text => "To Order" },
                         '31' => { :id => :out_of_stock, :text => "Out of Stock" },
                         '40' => { :id => :not_available, :text => "Not Available" }}


  PUBLISHER_STATUS = {'AB' => { :id => :canceled, :text => "Canceled" },
                      'CS' => { :id => :uncertain, :text => "Availability Uncertain" },
                      'EX' => { :id => :no_longer_stocked, :text => "No longer stocked by Ingram" },
                      'IP' => { :id => :available, :text => "In print and available" },
                      'NY' => { :id => :not_yet_published, :text => "Not yet published" },
                      'OI' => { :id => :out_of_stock, :text => "Out of stock indefinitely" },
                      'OP' => { :id => :out_of_print, :text => "Out of print" },
                      'PP' => { :id => :postponed, :text => "Postponed indefinitely" },
                      'RF' => { :id => :another_supplier, :text => "Referred to another supplier" },
                      'RM' => { :id => :remaindered, :text => "Remaindered" },
                      'TP' => { :id => :cant_supply, :text => "Temporarily out of stock because publisher cannot supply" },
                      'WS' => { :id => :withdrawn, :text => "Withdrawn from Sale" } }

  # Required for CDF Integration
  # BN = ISBN10
  # EN = EAN
  # UP = UPC
  def sku_type
    "EN"
  end

  def self.spec_test
    true
  end

  def ingram_product_type
    get_product_property(:ingram_product_type)
  end

  def ingram_product_type=(new_type)
    set_product_property :ingram_product_type, new_type.to_s
  end

  def availability_status
    get_product_property(:availability_status)
  end

  def availability_status=(new_type)
    set_product_property :availability_status, new_type.to_s
  end

  def publisher_status
    get_product_property(:publisher_status)
  end

  def publisher_status=(new_type)
    set_product_property :publisher_status, new_type.to_s
  end

  def self.setup_dropdowns
    types_array = PRODUCT_TYPES.map { |type| [type[1][:text], type[1][:id]] }
    available_array = AVAILABILITY_STATUS.map { |type| [type[1][:text], type[1][:id]] }
    status_array = PUBLISHER_STATUS.map { |type| [type[1][:text], type[1][:id]] }
    return { :types => types_array, :available => available_array, :status => status_array }
  end

  private

  def get_product_property(symbol)
    val = read_attribute(symbol)
    val.to_sym unless val.nil?
  end

  def set_product_property(symbol, new_value)
    write_attribute symbol, new_value.to_s
  end

end
