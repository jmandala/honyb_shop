class AddScacToAsnShipmentDetails < ActiveRecord::Migration
  def self.up
    add_column :asn_shipment_details, :scac, :string
  end

  def self.down
    remove_column :asn_shipment_details, :scac
  end
end
