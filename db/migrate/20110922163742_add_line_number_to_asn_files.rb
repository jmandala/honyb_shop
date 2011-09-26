class AddLineNumberToAsnFiles < ActiveRecord::Migration
  def self.up
    add_column :asn_shipments, :line_number, :integer    
    add_column :asn_shipment_details, :line_number, :integer    
  end

  def self.down
    remove_column :asn_shipments, :line_number
    remove_column :asn_shipment_details, :line_number
  end
end
