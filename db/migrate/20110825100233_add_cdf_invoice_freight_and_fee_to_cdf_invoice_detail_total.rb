class AddCdfInvoiceFreightAndFeeToCdfInvoiceDetailTotal < ActiveRecord::Migration
  def self.up
    add_column :cdf_invoice_detail_totals, :cdf_invoice_freight_and_fee_id, :integer
  end

  def self.down
    remove_column :cdf_invoice_detail_totals, :cdf_invoice_freight_and_fee_id
  end
end
