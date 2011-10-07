class RanameTrackingNumberToTrackingOnAsnShipmentDetail < ActiveRecord::Migration
  def self.up
    rename_column :asn_shipment_details, :tracking_number, :tracking
  end

  def self.down
    rename_column :asn_shipment_details, :tracking, :tracking_number    
  end
end
