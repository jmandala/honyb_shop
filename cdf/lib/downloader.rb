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
    IngramStockFile.download_all_new_delta_files do |downloaded_file|
      downloaded_file.import_core unless downloaded_file.nil?         # call import_core so as not to use the background delayed_job
    end
  end

  def self.download_and_import_inventory_file
    inventory_file = IngramStockFile.download_file nil, "stockv2@ingram.dat"
    inventory_file.import_core unless inventory_file.nil?           # call import_core so as not to use the background delayed_job
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