class AddParentIdToShipment < ActiveRecord::Migration
  def self.up
    add_column :shipments, :parent_id, :integer
  end

  def self.down
    remove_column :shipments, :parent_id
  end
end
