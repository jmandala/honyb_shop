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

  def get_biblio_data!
    book_info = GoogleBook.new self.sku

    return false if (book_info.nil? || book_info.matching_count == 0)

    self.name = book_info.title
    self.subtitle = book_info.subtitle
    self.description = book_info.description
    self.publisher = book_info.publisher
    self.published_date = book_info.published_date
    self.page_count = book_info.page_count
    begin
      thumbnail = book_info.thumbnail_url
      unless thumbnail.nil?
        img = Image.new
        img.attachment = open(URI.parse(thumbnail))
        self.images << img
      end
    rescue => e
      logger.error "An Error has occurred while downloading an image: #{e.message}. Image URL: #{thumbnail}"
    end

    authors = ""
    unless book_info.authors.nil?
      book_info.authors.each do |author|
        authors = authors + (authors.empty? ? "" : ", ") + author
      end
    end
    self.book_authors = authors

    self.google_books_update = Time.now
    self.save
    return true
  end

  def product_type
    return :book.to_s if self.ingram_product_type.nil?
    PRODUCT_TYPES.each do |type|
      if type[1][:id] == self.ingram_product_type
        return type[1][:text]
      end
    end
    self.ingram_product_type.to_s
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
