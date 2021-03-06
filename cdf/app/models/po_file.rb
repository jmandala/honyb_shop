require 'net/ftp'

class PoFile < ActiveRecord::Base

  #noinspection RailsParamDefResolve
  has_many :orders, :autosave => true, :dependent => :nullify, :order => 'completed_at asc'

  #noinspection RailsParamDefResolve
  has_many :poa_files, :dependent => :destroy, :order => 'created_at asc'

  after_create :init_file_name

  before_destroy :delete_file

  attr_reader :count

  PO_TYPE = {
      :purchase_order => '0',
      :request_confirmation => '1',
      :reserved_2 => '2',
      :stock_status_request => '3',
      :reserved_4 => '4',
      :specific_confirmation => '5',
      :request_confirmation_web_service => '7',
      :test_purchase_order => '8'
  }

  # todo: make a way to pass in the PO_TYPE
  def po_type
    if Cdf::Config[:cdf_run_mode].nil?
      Cdf::Config.set(:cdf_run_mode => :test)
    end

    if Cdf::Config[:cdf_run_mode].to_s == 'live'
      return PO_TYPE[:purchase_order].ljust_trim 1
    end
    
    PO_TYPE[:test_purchase_order].ljust_trim(1)

  end


  def read
    raise ArgumentError, "File not found: #{path}" unless has_file?

    File.read path
  end

  def has_file?
    self.persisted? ? File.exists?(path) : false
  end

  def initialize(attributes = nil, options = {})
    @count = init_counters
    super
  end

  # Generate a new PoFile from a given order
  def self.generate_from_order(order)
    PoFile.generate_core([] << order)
  end

  # Generates a new PoFile - by default, use every order that is ready for
  # shipment (limit 25)
  def self.generate
    PoFile.generate_core
  end

  def self.prefix
    ''
  end

  def self.ext
    '.fbo'
  end

  def delete_file
    if self.persisted? && File.exists?(path)
      FileUtils.rm path
      return true
    end

    false
  end

  def init_file_name
    self.file_name = self.class.prefix + self.created_at.strftime("%y%m%d%H%M%S") + self.class.ext
    save!
  end


  def po00
    Records::Po::Po00.new(file_name)
  end

  def po90
    Records::Po::Po90.new(@count[:total_records], :name => 'Po90', :count => @count)
  end


  def update_counters(order, po)
    @count[:total_records] += po.count[:total]
    @count[:total_purchase_orders] += 1
    @count[:total_line_items] += order.line_items.count
    @count[:total_units] += order.total_quantity

    (0..8).each { |i| @count[i.to_s] = po.count[i.to_s] }

  end

  def path
    raise Cdf::IllegalStateError, "Can't get path until PoFile has been saved" unless persisted?

    "#{CdfConfig::data_lib_out_root(self.created_at.strftime("%Y"))}/#{file_name}"
  end

  # Uploads this PoFile to the fulfillment server
  # @param client [CdfFtpClient] the client to use for submission. By default creates a new client.
  # @return [DateTime] time the file was submitted
  def put(client=CdfFtpClient.new)
    raise ArgumentError, "File not found: #{path}" unless File.exists?(path)

    return self.submitted_at if self.submitted?

    list = []
    client.connect do |ftp|
      ftp.chdir 'incoming'
      ftp.put File.new(path)
      list = ftp.list
    end

    self.submitted_at = Time.now
    self.save!
    self.submitted_at
  end

  # Returns true if already submitted
  def submitted?
    !self.submitted_at.nil?
  end

  # Returns PoFiles that have not been submitted
  def self.not_submitted
    where(:submitted_at => nil)
  end

  private
  def init_counters
    count = {
        :total_records => 2, # one for the header and one for the first order
        :total_purchase_orders => 0,
        :total_line_items => 0,
        :total_units => 0
    }

    for i in 0..8 do
      count[i.to_s] = 0
    end
    count
  end

  # Generates a new PoFile - by default, use every order that is ready for
  # shipment (limit 25), or pass in your own array of orders that need PO files
  def self.generate_core(orders=Order.needs_po.limit(25))
    po_file = PoFile.new
    po_file.save!

    data = po_file.po00.cdf_record + Records::Base::LINE_TERMINATOR

    orders.each do |order|
      po_file.orders << order
      po = order.as_cdf(po_file.count[:total_records])
      data << po.to_s
      po_file.update_counters(order, po)
    end

    data << po_file.po90.cdf_record

    FileUtils.mkdir_p(File.dirname(po_file.path))
    File.open(po_file.path, 'w') { |f| f.write data }

    po_file.save!
    po_file
  end


end