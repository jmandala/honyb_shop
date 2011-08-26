class AddOrderToCdfInvoiceFreightAndFee < ActiveRecord::Migration
  def self.up
    add_column :cdf_invoice_freight_and_fees, :order_id, :integer
  end

  def self.down
    remove_column :cdf_invoice_freight_and_fees, :order_id
  end
end
