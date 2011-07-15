class CreateInvoiceFileImportRecords < ActiveRecord::Migration
  extend CdfTable

  def self.up
    
    create_table :cdf_invoice_files do |t|
      t.string :record_code, :limit => 2
      t.string :sequence, :limit => 5
      t.integer :ingram_san
      t.string :file_source, :limit => 13
      t.datetime :creation_date
      t.string :ingram_file_name, :limit => 22
      t.string :file_name
      t.datetime :imported_at
      t.timestamps
    end
    
    create_table :cdf_invoice_headers do |t|
      default_inv_columns t
      t.integer :company_account_id_number
      t.integer :warehouse_san
      t.datetime :invoice_date
    end

    create_table :cdf_invoice_isbn_details do |t|
      default_inv_columns t
      t.string :isbn_10_shipped
      t.integer :quantity_shipped
      t.decimal :ingram_list_price, :precision => 7, :scale => 2, :default => 0.0, :null => false
      t.decimal :discount, :precision => 4, :scale => 2, :default => 0.0, :null => false
      t.decimal :net_price, :precision => 8, :scale => 2, :default => 0.0, :null => false
      t.datetime :metered_date

    end

    create_table :cdf_invoice_ean_details do |t|
      default_inv_columns t
      t.string :ean_shipped, :limit => 14
    end

    create_table :cdf_invoice_detail_totals do |t|
      default_inv_columns t
      t.string :title, :limit => 16
      t.integer :client_order_id
      t.string :line_item_id_number
      t.references :order
      t.references :line_item
    end

    create_table :cdf_invoice_freight_and_fees do |t|
      default_inv_columns t
      t.integer :tracking_number
      t.decimal :net_price, :precision => 8, :scale => 2, :default => 0.0, :null => false
      t.decimal :shipping, :precision => 6, :scale => 2, :default => 0.0, :null => false
      t.decimal :handling, :precision => 7, :scale => 2, :default => 0.0, :null => false
      t.decimal :gift_wrap, :precision => 6, :scale => 2, :default => 0.0, :null => false
      t.decimal :amount_due, :precision => 7, :scale => 2, :default => 0.0, :null => false
    end

    create_table :cdf_invoice_totals do |t|
      default_inv_columns t
      t.integer :invoice_record_count
      t.integer :number_of_titles
      t.integer :total_number_of_units
      t.string :bill_of_lading, :limit => 10
      t.integer :total_invoice_weight
    end

    create_table :cdf_invoice_trailers do |t|
      default_inv_columns t
      t.decimal :total_net_price, :precision => 9, :scale => 2, :default => 0.0, :null => false
      t.decimal :total_shipping, :precision => 7, :scale => 2, :default => 0.0, :null => false
      t.decimal :total_handling, :precision => 7, :scale => 2, :default => 0.0, :null => false
      t.decimal :total_gift_wrap, :precision => 6, :scale => 2, :default => 0.0, :null => false
      t.decimal :total_invoice, :precision => 9, :scale => 2, :default => 0.0, :null => false

    end

    create_table :cdf_invoice_file_trailers do |t|
      t.string :record_code, :limit => 2
      t.string :sequence, :limit => 5
      t.timestamps
      t.integer :total_titles
      t.integer :total_invoices
      t.integer :total_units
      t.references :cdf_invoice_file

    end
    
  end

  def self.down
    drop_table :cdf_invoice_file_trailers
    drop_table :cdf_invoice_trailers
    drop_table :cdf_invoice_totals
    drop_table :cdf_invoice_freight_and_fees
    drop_table :cdf_invoice_detail_totals
    drop_table :cdf_invoice_ean_details
    drop_table :cdf_invoice_isbn_details
    drop_table :cdf_invoice_headers
    drop_table :cdf_invoice_files
  end
end
