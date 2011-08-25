class AddCdfInvoiceDetailsReferencesToCdfInvoiceDetailTotal < ActiveRecord::Migration
  def self.up
    add_column :cdf_invoice_detail_totals, :cdf_invoice_isbn_detail_id, :integer
    add_column :cdf_invoice_detail_totals, :cdf_invoice_ean_detail_id, :integer
  end

  def self.down
    remove_column :cdf_invoice_detail_totals, :cdf_invoice_ean_detail_id
    remove_column :cdf_invoice_detail_totals, :cdf_invoice_isbn_detail_id
  end
end
