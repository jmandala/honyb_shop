class AddBillOfLadingNumberToCdfInvoiceTotal < ActiveRecord::Migration
  def self.up
    add_column :cdf_invoice_totals, :bill_of_lading_number, :string
  end

  def self.down
    remove_column :cdf_invoice_totals, :bill_of_lading_number
  end
end
