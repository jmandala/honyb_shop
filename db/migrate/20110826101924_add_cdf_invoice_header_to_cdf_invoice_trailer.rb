class AddCdfInvoiceHeaderToCdfInvoiceTrailer < ActiveRecord::Migration
  def self.up
    #add_column :cdf_invoice_trailers, :cdf_invoice_header_id, :integer
  end

  def self.down
    #remove_column :cdf_invoice_trailers, :cdf_invoice_header_id    
  end
end
