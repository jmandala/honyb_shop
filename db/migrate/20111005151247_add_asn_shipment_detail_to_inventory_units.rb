class AddAsnShipmentDetailToInventoryUnits < ActiveRecord::Migration
  def self.up
    add_column :inventory_units, :asn_shipment_detail_id, :integer
  end

  def self.down
    remove_column :inventory_units, :asn_shipment_detail_id
  end
end
