class Downloader
  def self.download_poa_files
    self.download_files PoaFile
  end

  def self.download_asn_files
    self.download_files AsnFile
  end

  def self.download_cdf_invoice_files
    self.download_files CdfInvoiceFile
  end

  def self.download_and_import_stock_delta_files
    local_files = IngramStockFile.all(:limit => 6, :order => "file_date DESC")
    first_date = nil
    delta_letter = 'a'
    unless local_files.nil?
      first_date = local_files[0].file_date unless local_files.empty?
      local_files.each do |local_file|
        if first_date == local_file.file_date
          /stockv2delta\d{6}(?<file_letter>[a-f])@ingram.dat/ =~ local_file.file_name
          if compare_letters(file_letter, delta_letter)
            delta_letter = file_letter
          end
        else
          break
        end
      end
    end

    new_files = IngramStockFile.download
    unless new_files.nil?
      new_files.each do |file|
        file_date = file.find_file_date!
        if !file_date.nil? && (first_date.nil? || file_date >= first_date) && compare_letters(file.get_delta_letter, delta_letter)
          file.import
        end
      end
    end
  end

  def download_and_import_inventory_file
    inventory_file = IngramStockFile.download_file nil, "stockv2@ingram.dat"
    inventory_file.import unless inventory_file.nil?
  end

  private

  def compare_letters letter_one, letter_two
    return letter_two if letter_one.nil?
    return letter_one if letter_two.nil?

    return (letter_one > letter_two)
  end

  def self.download_files(class_instance)
    puts "downloading files"

    files = []

    begin
      if class_instance.respond_to?(:download)
        class_instance.download
        files = class_instance.import_all
      else
        Rails.logger.error "Error: download called for a Model (#{class_instance.to_s}) that doesn't support the download method!"
      end
    rescue => e
      message = "Error downloading. #{e.message}. #{e.backtrace.slice(0, 15)}"
      Rails.logger.error message
      Rails.logger.error e.backtrace.slice(0, 15)
      CdfImportExceptionLog.create(:event => message, :file_name => self.file_name)
    end

    puts "Downloaded and stored #{files.count} #{class_instance.to_s} Files"

    return files.count
  end
end