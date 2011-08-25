class DeleteBillOfLadingFromCdfInvoiceTotal < ActiveRecord::Migration
  def self.up
    remove_column :cdf_invoice_totals, :bill_of_lading
  end

  def self.down
    add_column :cdf_invoice_totals, :bill_of_lading, :string, :limit => 10
  end
end
