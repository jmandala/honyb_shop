class CreatePoaVendorRecords < ActiveRecord::Migration
  extend CdfTable

  def self.up
    create_table :poa_vendor_records do |t|
      default_poa_columns t
      t.string 'vendor_message', :limit => 50
    end
  end

  def self.down
    drop_table :poa_vendor_records
  end
end
