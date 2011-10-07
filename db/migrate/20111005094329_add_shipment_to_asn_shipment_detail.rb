class AddShipmentToAsnShipmentDetail < ActiveRecord::Migration
  def self.up
    add_column :asn_shipment_details, :shipment_id, :integer
  end

  def self.down
    remove_column :asn_shipment_details, :shipment_id
  end
end
