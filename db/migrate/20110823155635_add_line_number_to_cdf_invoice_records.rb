class AddLineNumberToCdfInvoiceRecords < ActiveRecord::Migration
  def self.up
    add_column :cdf_invoice_detail_totals, :line_number, :integer
    add_column :cdf_invoice_ean_details, :line_number, :integer
    add_column :cdf_invoice_file_trailers, :line_number, :integer
    add_column :cdf_invoice_files, :line_number, :integer
    add_column :cdf_invoice_freight_and_fees, :line_number, :integer
    add_column :cdf_invoice_isbn_details, :line_number, :integer
    add_column :cdf_invoice_totals, :line_number, :integer
    add_column :cdf_invoice_trailers, :line_number, :integer
    add_column :cdf_invoice_headers,  :line_number, :integer        
  end

  def self.down
    remove_column :cdf_invoice_detail_totals, :line_number
    remove_column :cdf_invoice_ean_details, :line_number
    remove_column :cdf_invoice_file_trailers, :line_number
    remove_column :cdf_invoice_files, :line_number
    remove_column :cdf_invoice_freight_and_fees, :line_number
    remove_column :cdf_invoice_isbn_details, :line_number
    remove_column :cdf_invoice_totals, :line_number
    remove_column :cdf_invoice_trailers, :line_number
    remove_column :cdf_invoice_headers,  :line_number
  end
end
