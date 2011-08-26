class RemoveInvoiceFreightAndFeeFromCdfInvoiceDetailTotal < ActiveRecord::Migration
  def self.up
    remove_column :cdf_invoice_detail_totals, :cdf_invoice_freight_and_fee_id
  end

  def self.down
    add_column :cdf_invoice_detail_totals, :cdf_invoice_freight_and_fee_id, :integer    
  end
end
