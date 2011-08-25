class AddAsnShippingMethodCodeIdToAsnShipments < ActiveRecord::Migration
  def self.up
    add_column :asn_shipment_details, :asn_shipping_method_code_id, :integer
    remove_column :asn_shipment_details, :shipping_method_code
  end

  def self.down
    remove_column :asn_shipment_details, :asn_shipping_method_code_id
    add_column :asn_shipment_details, :shipping_method_code, :string
  end
end
