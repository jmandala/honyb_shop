class CreateMorePoaTables < ActiveRecord::Migration
  extend CdfTable

  def self.up

    add_column :poa_files, :po_file_id, :integer
    remove_column :poa_order_headers, :po_file_id
    add_column :poa_order_headers, :order_id, :integer
    add_column :poa_vendor_records, :poa_order_header_id, :integer

    create_table :poa_ship_to_names do |t|
      default_poa_columns t
      t.references :poa_order_header
      t.string 'recipient_name', :limit => 35
    end

    create_table :poa_address_lines do |t|
      default_poa_columns t
      t.references :poa_order_header
      t.string 'recipient_address_line', :limit => 35
    end

    create_table :poa_city_state_zips do |t|
      default_poa_columns t
      t.references :poa_order_header
      t.string 'recipient_city', :limit => 25
      t.references :state
      t.string 'recipient_state_province', :limit => 3
      t.string 'zip_postal_code', :limit => 11
      t.references :country
    end

    create_table :poa_line_items do |t|
      default_poa_columns t
      t.references :poa_order_header
      t.string 'line_item_po_number', :limit => 10
      t.string 'item_number', :limit => 20
      t.references :poa_status
      t.references :dc_code
      t.references :product
    end

    create_table :dc_codes do |t|
      t.string 'po_dc_code', :limit => 1
      t.string 'poa_dc_code', :limit => 1
      t.string 'asn_dc_code', :limit => 2
      t.string 'inv_dc_san', :limit => 10
      t.string 'dc_name', :limit => 50
      t.timestamps
    end

    create_table :poa_additional_details do |t|
      default_poa_columns t
      t.references :poa_order_header
      t.datetime 'availability_date'
      t.string 'dc_inventory_information', :limit => 40
    end

    create_table :cdf_binding_codes do |t|
      t.string 'code', :limit => 1
      t.string 'name', :limit => 20

      t.timestamps
    end

    create_table :poa_line_item_title_records do |t|
      default_poa_columns t
      t.references :poa_order_header
      t.string 'title', :limit => 30
      t.string 'author', :limit => 20
      t.integer 'cdf_binding_code_id'
    end

    create_table :poa_line_item_pub_records do |t|
      default_poa_columns t
      t.references :poa_order_header
      t.string 'publisher_name', :limit => 20
      t.datetime 'publication_release_date'
      t.string 'original_seq_number', :limit => 5
      t.string 'total_qty_predicted_to_ship_primary', :limit => 7
    end

    create_table :poa_item_number_price_records do |t|
      default_poa_columns t
      t.references :poa_order_header
      t.decimal :net_price, :precision => 8, :scale => 2
      t.string :item_number_type, :limit => 2
      t.decimal :discounted_list_price, :precision => 8, :scale => 2
      t.integer :total_line_order_qty
    end

    create_table :poa_control_totals do |t|
      default_poa_columns t
      t.references :poa_order_header
      t.integer :record_count
      t.integer :total_line_items_in_file
      t.integer :total_units_acknowledged
    end

  end

  def self.down
    remove_column :poa_files, :po_file_id
    begin
      add_column :poa_order_headers, :po_file_id, :integer
      remove_column :poa_order_headers, :order_id
      remove_column :poa_vendor_records, :poa_order_header_id
    rescue
    end

    drop_table :poa_ship_to_names
    drop_table :poa_address_lines
    drop_table :poa_city_state_zips
    drop_table :poa_line_items
    drop_table :dc_codes
    drop_table :poa_additional_details
    drop_table :cdf_binding_codes
    drop_table :poa_line_item_title_records
    drop_table :poa_line_item_pub_records
    drop_table :poa_item_number_price_records
    drop_table :poa_control_totals
  end
end