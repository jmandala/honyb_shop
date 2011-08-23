class RenameSequenceInCdfInvoiceTables < ActiveRecord::Migration
  def self.up
    rename_column :cdf_invoice_detail_totals, :sequence, :sequence_number
    rename_column :cdf_invoice_ean_details, :sequence, :sequence_number
    rename_column :cdf_invoice_file_trailers, :sequence, :sequence_number
    rename_column :cdf_invoice_files, :sequence, :sequence_number
    rename_column :cdf_invoice_freight_and_fees, :sequence, :sequence_number
    rename_column :cdf_invoice_isbn_details, :sequence, :sequence_number
    rename_column :cdf_invoice_totals, :sequence, :sequence_number
    rename_column :cdf_invoice_trailers, :sequence, :sequence_number
  end

  def self.down
    rename_column :cdf_invoice_detail_totals, :sequence_number, :sequence
    rename_column :cdf_invoice_ean_details, :sequence_number, :sequence
    rename_column :cdf_invoice_file_trailers, :sequence_number, :sequence
    rename_column :cdf_invoice_files, :sequence_number, :sequence
    rename_column :cdf_invoice_freight_and_fees, :sequence_number, :sequence
    rename_column :cdf_invoice_isbn_details, :sequence_number, :sequence
    rename_column :cdf_invoice_totals, :sequence_number, :sequence
    rename_column :cdf_invoice_trailers, :sequence_number, :sequence
  end
end
