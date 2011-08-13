class AddPoNumberToAsnShipmentDetails < ActiveRecord::Migration
  def self.up
    add_column :asn_shipment_details, :po_number, :string
  end

  def self.down
    remove_column :asn_shipment_details, :po_number
  end
end
