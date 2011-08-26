class AddCdfInvoiceDetailTotalToCdfInvoiceFreightAndFees < ActiveRecord::Migration
  def self.up
    add_column :cdf_invoice_freight_and_fees, :cdf_invoice_detail_total_id, :integer
  end

  def self.down
    remove_column :cdf_invoice_freight_and_fees, :cdf_invoice_detail_total_id
  end
end
