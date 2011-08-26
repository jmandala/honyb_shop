class ChangeTypeForTrackingNumberOnCdfInvoiceFreightAndFee < ActiveRecord::Migration
  def self.up
    change_column :cdf_invoice_freight_and_fees, :tracking_number, :string
  end

  def self.down
    change_column :cdf_invoice_freight_and_fees, :tracking_number, :integer
  end
end
