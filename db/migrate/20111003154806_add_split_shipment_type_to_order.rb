class AddSplitShipmentTypeToOrder < ActiveRecord::Migration
  def self.up
    add_column :orders, :split_shipment_type, :string
  end

  def self.down
    remove_column :orders, :split_shipment_type
  end
end
