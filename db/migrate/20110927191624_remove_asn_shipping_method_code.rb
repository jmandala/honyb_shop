class RemoveAsnShippingMethodCode < ActiveRecord::Migration
  def self.up
    remove_column :asn_shipment_details, :asn_shipping_method_code
  end

  def self.down
    add_column :asn_shipment_details, :asn_shipping_method_code, :integer
  end
end
