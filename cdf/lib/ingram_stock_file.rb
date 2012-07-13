require 'zip/zip'

class IngramStockFile < ActiveRecord::Base
  include Importable

  has_many :versions, :class_name => 'IngramStockFile', :foreign_key => 'parent_id', :autosave => true
  belongs_to :parent, :class_name => 'IngramStockFile'

  define_ext 'zip'
  define_length 300
  support_versioning false
  define_ftp_dirs ['Inventory']
  define_ftp_server_connection Cdf::Config[:cdf_ftp_inventory_server], Cdf::Config[:cdf_ftp_inventory_user], Cdf::Config[:cdf_ftp_inventory_password], false, :live

  @collaborators = []

  import_format do |r|
    r.body do |record|
      record.trap { |line| line }
      record.gtin_prefix 1
      record.ean 13
      record.upc 14
      record.isbn_10 10
      record.la_vergne_on_hand 7
      record.roseburg_on_hand 7
      record.ft_wayne_on_hand 7
      record.chambersburg_on_hand 7
      record.spacer 7
      record.spacer 7
      record.spacer 7
      record.spacer 7
      record.la_vergne_on_order 7
      record.roseburg_on_order 7
      record.ft_wayne_on_order 7
      record.chambersburg_on_order 7
      record.spacer 7
      record.spacer 7
      record.spacer 7
      record.spacer 7
      record.list_price 7
      record.publisher_price 7
      record.spacer 1
      record.discount_level 3
      record.spacer 10
      record.publisher_status_code 2
      record.la_vergne_stock_flag 1
      record.roseburg_stock_flag 1
      record.ft_wayne_stock_flag 1
      record.chambersburg_stock_flag 1
      record.spacer 1
      record.spacer 1
      record.spacer 1
      record.spacer 1
      record.publication_date 8
      record.on_sale_date 8
      record.returnable_indicator 1
      record.return_date 8
      record.print_on_demand_indicator 1
      record.spacer 4
      record.backorder_only_indicator 1
      record.media_mail_indicator 1
      record.product_type 1
      record.imprintable_indicator 1
      record.indexable_indicator 1
      record.spacer 15
      record.weight 6
      record.spacer 11
      record.ingram_publisher_number 4
      record.spacer 5
      record.restricted_code 1
      record.discount_category_code 5
      record.spacer 1
      record.product_availability_code 2
      record.ingram_title_code 9
      record.product_classification_type 2
      record.spacer 16
    end
  end

  AVAILABLE_IMMEDIATELY = "00010101"

  def create_product(product_info)
    # Product fields
    available_on = (product_info[:on_sale_date] == AVAILABLE_IMMEDIATELY) ? Date.today.to_datetime : product_info[:on_sale_date].to_datetime
    type = PRODUCT_TYPES[product_info[:product_type]]
    ingram_product_type = type.nil? ? nil : type[:id]
    availability = AVAILABILITY_STATUS[product_info[:product_availability_code]]
    availability_status = availability.nil? ? nil : availability[:id]
    status = PUBLISHER_STATUS[product_info[:publisher_status_code]]
    publisher_status = status.nil? ? nil : status[:id]

    # Master Variant fields
    price = product_info[:list_price].to_d / 100
    count_on_hand = product_info[:la_vergne_on_hand].to_i +
                    product_info[:roseburg_on_hand].to_i +
                    product_info[:ft_wayne_on_hand].to_i +
                    product_info[:chambersburg_on_hand].to_i

    variant = Variant.includes(:product).find_by_sku(product_info[:ean])   # check if this is a new product, or an update to an existing one
    action = :none
    if variant.nil?
      # New Product - perform a regular save, triggering all the validations and callbacks
      product = Product.new
      product.name = product_info[:ean]
      product.sku = product_info[:ean]
      product.price = price
      product.count_on_hand = count_on_hand
      product.available_on = available_on
      product.ingram_product_type = ingram_product_type
      product.availability_status = availability_status
      product.publisher_status = publisher_status
      product.ingram_updated_at = Time.now
      product.save
      action = :create
    else
      # Update of an existing record - do a fast db update using update_all, without validations or callbacks (and cross your fingers...)
      variant_hash = {}
      variant_hash[:price] = price unless (price == variant.price)
      variant_hash[:count_on_hand] = count_on_hand unless (count_on_hand == variant.count_on_hand)
      Variant.update_all(variant_hash, :id => variant.id) unless variant_hash.empty?

      product_hash = {}
      product_hash[:available_on] = available_on unless ((available_on == variant.product.available_on) || ((product_info[:on_sale_date] == AVAILABLE_IMMEDIATELY) && (variant.product.available_on < Date.today)))
      product_hash[:ingram_product_type] = ingram_product_type unless (ingram_product_type == variant.product.ingram_product_type)
      product_hash[:availability_status] = availability_status unless (availability_status == variant.product.availability_status)
      product_hash[:publisher_status] = publisher_status unless (publisher_status == variant.product.publisher_status)
      product_hash[:ingram_updated_at] = Time.now unless product_hash.empty?
      Product.update_all(product_hash, :id => variant.product_id) unless product_hash.empty?

      action = :update unless (variant_hash.empty? && product_hash.empty?)
    end

    return action
  end

  def self.delayed_import object
    begin
      if object.downloaded_at.nil?
        result = IngramStockFile.download_file nil, object.file_name

        if result
          result.downloaded_at = Time.now
          result.save!
          object = result
          puts "Completed downloading #{object.file_name} at #{result.downloaded_at}"
        end
      end
      result = object.import
      puts "Queued import of #{object.file_name} at #{Time.now}."

    rescue => e
      logger.error "Failed to import #{object.file_name}. #{e.message}"
      logger.error e.backtrace
      raise e
    end
  end

  def import
    if import_error?
      return CdfImportExceptionLog.create(:event => "Error importing file: #{import_error_message}", :file_name => self.file_name)
    end

    self.import_queued_at = Time.now
    self.save

    prefix = self.generate_part_file_prefix
    part_files = Dir["#{CdfConfig::current_data_lib_in}/#{prefix}*"]
    part_files.each do |part_file|
      self.delay.import_part_file part_file, (part_file == part_files.last)          # let delayed_job process each of the parts file in the background
    end
  end

  # we've split up the large Ingram inventory file into more manageable parts, now import each one
  def import_part_file part_file_name, last_part_file
    begin
      start_time = Time.now
      puts "**** Starting import of Ingram stock records from #{part_file_name} at #{start_time}"
      temp_file = IngramStockFile.new(:file_name => File.basename(part_file_name), :created_at => Time.now)
      p = temp_file.parsed
      count_products = 0
      count_updated_products = 0
      count_created_products = 0
      IngramStockFile.transaction do
        p[:body].each do |product_data|
          case create_product product_data
            when :update
              count_updated_products += 1
            when :create
              count_created_products += 1
          end
          count_products += 1
        end
      end
      p = nil
      temp_file = nil

      end_time = Time.now
      avg_speed = (count_products > 0) ? ((end_time - start_time)/count_products*1000).round(3) : "N/A"
      puts "**** Processed #{count_products} stock records, (#{count_updated_products} updates and #{count_created_products} creates) from file #{part_file_name} in #{(end_time - start_time).round} seconds. Average speed #{avg_speed} per 1000 records"

      File.delete part_file_name      # delete the temporary part file

      if last_part_file
        self.import_queued_at = nil
        self.imported_at = Time.now
        # need a self.save here, but the import_stats code below needs a save also - make sure to put a save here, if that code is ever removed!
      end

      stats = self.import_stats
      unless stats.nil?
        if (/(?<records_count>^\d+) Records; Average Time per 1000: (?<avg_record_time>\d{2}\.\d{3})/ =~ stats)
          count_products += records_count.to_i
          avg_speed = (((avg_record_time.to_f * records_count.to_f / 1000) + (end_time - start_time))/count_products * 1000).round(3)
        end
      end
      # there could, potentially be a concurrency problem here, but this is informational only, so it's ok if we lose an update
      self.import_stats = "#{count_products} Records; Average Time per 1000: #{avg_speed}"
      self.save

    rescue => e
     CdfImportExceptionLog.create(:event => e.message, :file_name => part_file_name, :backtrace => e.backtrace)
     raise e
    end

  end

  def self.download_all_new_delta_files
    last_delta_file = IngramStockFile.all(:limit => 1, :order => "file_date DESC")
    last_delta_file_name = last_delta_file.blank? ? nil : last_delta_file[0].file_name
    last_delta_file_name = last_delta_file_name[0, last_delta_file_name.length - 4] unless last_delta_file_name.nil?

    downloadable = IngramStockFile.remote_files
    downloadable.each do |file|
      file_name = CdfFtpClient.name_from_path(file)
      file_info = IngramStockFile.file_name_useful_to_honyb file_name
      if (file_info[:useful_file] && !file_info[:full_file] && file_name[0, file_name.length - (@ext.length+1)] > last_delta_file_name)    # download only the files we care about, and ones that are newer than the latest one we've already got
        download_file = IngramStockFile.download_file nil, file_name
        download_file.downloaded_at = Time.now unless download_file.nil?
        yield download_file
      end
    end

  end

  def find_file_date!
    return self.file_date unless self.file_date.nil?

    /stockv2delta(?<file_date>\d{6})[a-f]@ingram.\w{3}/ =~ self.file_name
    parsed_date = nil
    parsed_date = Date.strptime(file_date, "%y%m%d") unless file_date.nil?

    self.file_date = parsed_date
    self.save

    parsed_date
  end

  def get_delta_letter
    /stockv2delta\d{6}(?<file_letter>[a-f])@ingram.\w{3}/ =~ self.file_name

    file_letter
  end

  def delta_date
    self.file_date.nil? ? "Full File" : self.file_date
  end

  def generate_part_file_prefix
    "delta#{self.find_file_date!}#{self.get_delta_letter}_parts_"
  end

  # we are looking for stockv2@ingram.zip (full inventory file) or a stockv2deltaXXXXXX[a-f]@ingram.zip (daily delta file)
  def self.file_name_useful_to_honyb file_name
    file_date = nil
    full_file = (file_name  == "stockv2@ingram.zip")
    if full_file
      useful_file = true
    else
      useful_file = !(/stockv2delta(?<file_date>\d{6})[a-f]@ingram.zip/ =~ file_name).nil?
    end

    return { :useful_file => (full_file || useful_file), :full_file => full_file, :file_date => file_date }
  end

end