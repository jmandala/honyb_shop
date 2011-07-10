class CreateAsnRecords < ActiveRecord::Migration
  def self.up

    create_table :asn_slash_codes do |t|
      t.string :code
      t.string :description
      t.timestamps
    end

    create_table :asn_order_statuses do |t|
      t.string :code
      t.string :description
      t.timestamps
    end

    create_table :asn_files do |t|
      t.string    :record_code, :limit => 2
      t.string    :file_name
      t.datetime  :imported_at
      t.string    :company_account_id_number, :limit => 10
      t.integer   :total_order_count
      t.string    :file_version_number, :limit => 10
      t.timestamps
    end

    create_table :asn_shipments do |t|
      t.references  :asn_file
      t.string      :record_code, :limit => 2
      t.references  :order
      t.references  :asn_order_status
      t.decimal     :order_subtotal, :precision => 8, :scale => 2, :default => 0.0, :null => false
      t.decimal     :order_discount_amount, :precision => 8, :scale => 2, :default => 0.0, :null => false
      t.decimal     :sales_tax, :precision => 8, :scale => 2, :default => 0.0, :null => false
      t.decimal     :shipping_and_handling, :precision => 8, :scale => 2, :default => 0.0, :null => false

      # order_total includes subtotal, misc charges, tax, shipping and any discount
      t.decimal     :order_total, :precision => 8, :scale => 2, :default => 0.0, :null => false

      # actual freight charge
      t.decimal     :freight_charge, :precision => 8, :scale => 2, :default => 0.0, :null => false

      t.integer     :total_item_detail_count

      t.datetime    :shipment_date

      # secondary po number. Example Consumer Corporate PO Number
      t.string      :consumer_po_number, :limit => 22

      t.timestamps
    end

    create_table :asn_shipment_details do |t|
      t.references  :asn_file
      t.string      :record_code, :limit => 2
      t.references  :order
      t.references  :dc_code
      t.string      :ingram_order_entry_number, :limit => 10
      t.integer     :quantity_canceled
      t.string      :isbn_10_ordered
      t.string      :isbn_10_shipped
      t.integer     :quantity_predicted
      t.integer     :quantity_slashed
      t.integer     :quantity_shipped
      t.references  :asn_order_status
      t.string      :tracking_number
      t.string      :standard_carrier_address_code
      t.decimal     :ingram_item_list_price, :precision => 8, :scale => 2, :default => 0.0, :null => false
      t.decimal     :net_discounted_price, :precision => 8, :scale => 2, :default => 0.0, :null => false
      t.string      :line_item_number
      t.references  :line_item
      # secondary tracking number
      t.string      :ssl, :limit => 20
      t.decimal     :weight, :precision => 9, :scale => 2, :default => 0.0, :null => false
      t.string      :shipping_method_code
      t.references  :asn_slash_code
      t.string      :isbn_13
      t.references  :product
      t.timestamps
    end

  end

  def self.down
    drop_table :asn_order_statuses
    drop_table :asn_slash_codes
    drop_table :asn_files
    drop_table :asn_shpiments
    drop_table :asn_shpiment_details
  end
end
