class AddPoNumberToAsnShipment < ActiveRecord::Migration
  def self.up
    add_column :asn_shipments, :po_number, :string
  end

  def self.down
    remove_column :asn_shipments, :po_number
  end
end
