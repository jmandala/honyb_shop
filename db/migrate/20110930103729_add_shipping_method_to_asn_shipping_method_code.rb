class AddShippingMethodToAsnShippingMethodCode < ActiveRecord::Migration
  def self.up
    rename_column :asn_shipping_method_codes, :shipping_method, :name
    add_column :asn_shipping_method_codes, :shipping_method_id, :integer
  end

  def self.down
    rename_column :asn_shipping_method_codes, :name, :shipping_method    
    remove_column :asn_shipping_method_codes, :shipping_method_id
  end
end
