class AddAsnShipmentIdToAsnShipmentDetails < ActiveRecord::Migration
  def self.up
    add_column :asn_shipment_details, :asn_shipment_id, :integer
  end

  def self.down
    remove_column :asn_shipment_details, :asn_shipment_id
  end
end
