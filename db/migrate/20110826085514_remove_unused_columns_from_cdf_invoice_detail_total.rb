class RemoveUnusedColumnsFromCdfInvoiceDetailTotal < ActiveRecord::Migration
  def self.up
    remove_column :cdf_invoice_detail_totals, :client_order_id
    remove_column :cdf_invoice_detail_totals, :line_item_id_number
  end

  def self.down
    add_column :cdf_invoice_detail_totals, :client_order_id, :integer
    add_column :cdf_invoice_detail_totals, :line_item_id_number, :string
  end
end
