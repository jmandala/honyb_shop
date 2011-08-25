class RemoveLineItemNumberFromAsnShipmentDetails < ActiveRecord::Migration
  def self.up
    remove_column :asn_shipment_details, :line_item_number
  end

  def self.down
    add_column :asn_shipment_details, :line_item_number, :string
  end
end
