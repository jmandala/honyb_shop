class AddCdfInvoiceHeaderToCdfInvoiceTrailer < ActiveRecord::Migration
  def self.up
    begin
      add_column :cdf_invoice_trailers, :cdf_invoice_header_id, :integer
    rescue => e
      puts e.message
    end

  end

  def self.down
    begin
      remove_column :cdf_invoice_trailers, :cdf_invoice_header_id    
    rescue => e
      puts e.message
    end
  end
end
