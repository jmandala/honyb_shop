# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120717061227) do

  create_table "activators", :force => true do |t|
    t.string   "description"
    t.datetime "expires_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "starts_at"
    t.string   "name"
    t.string   "event_name"
    t.string   "type"
  end

  create_table "address_types", :force => true do |t|
    t.string "code"
    t.string "name"
  end

  create_table "addresses", :force => true do |t|
    t.string   "firstname"
    t.string   "lastname"
    t.string   "address1"
    t.string   "address2"
    t.string   "city"
    t.integer  "state_id"
    t.string   "zipcode"
    t.integer  "country_id"
    t.string   "phone"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "state_name"
    t.string   "alternative_phone"
  end

  add_index "addresses", ["firstname"], :name => "index_addresses_on_firstname"
  add_index "addresses", ["lastname"], :name => "index_addresses_on_lastname"

  create_table "adjustments", :force => true do |t|
    t.integer  "order_id"
    t.decimal  "amount"
    t.string   "label"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "source_id"
    t.string   "source_type"
    t.boolean  "mandatory"
    t.boolean  "locked"
    t.integer  "originator_id"
    t.string   "originator_type"
    t.boolean  "eligible",        :default => true
  end

  add_index "adjustments", ["order_id"], :name => "index_adjustments_on_order_id"

  create_table "affiliates", :force => true do |t|
    t.string   "affiliate_key",     :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "logo_file_name"
    t.string   "logo_content_type"
    t.integer  "logo_file_size"
    t.datetime "logo_updated_at"
    t.string   "name"
    t.text     "why_buy_text"
    t.text     "css"
  end

  add_index "affiliates", ["affiliate_key"], :name => "honyb_id", :unique => true

  create_table "asn_files", :force => true do |t|
    t.string   "record_code",               :limit => 2
    t.string   "file_name"
    t.datetime "imported_at"
    t.string   "company_account_id_number", :limit => 10
    t.integer  "total_order_count"
    t.string   "file_version_number",       :limit => 10
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "parent_id"
  end

  create_table "asn_order_statuses", :force => true do |t|
    t.string   "code"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "asn_shipment_details", :force => true do |t|
    t.integer  "asn_file_id"
    t.string   "record_code",                   :limit => 2
    t.integer  "order_id"
    t.integer  "dc_code_id"
    t.string   "ingram_order_entry_number",     :limit => 10
    t.integer  "quantity_canceled"
    t.string   "isbn_10_ordered"
    t.string   "isbn_10_shipped"
    t.integer  "quantity_predicted"
    t.integer  "quantity_slashed"
    t.integer  "quantity_shipped"
    t.integer  "asn_order_status_id"
    t.string   "tracking"
    t.string   "standard_carrier_address_code"
    t.decimal  "ingram_item_list_price",                      :default => 0.0, :null => false
    t.decimal  "net_discounted_price",                        :default => 0.0, :null => false
    t.integer  "line_item_id"
    t.string   "ssl",                           :limit => 20
    t.decimal  "weight",                                      :default => 0.0, :null => false
    t.integer  "asn_slash_code_id"
    t.string   "isbn_13"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "scac"
    t.integer  "asn_shipping_method_code_id"
    t.integer  "asn_shipment_id"
    t.integer  "line_number"
    t.integer  "shipment_id"
  end

  create_table "asn_shipments", :force => true do |t|
    t.integer  "asn_file_id"
    t.string   "record_code",             :limit => 2
    t.integer  "order_id"
    t.integer  "asn_order_status_id"
    t.decimal  "order_subtotal",                        :precision => 8, :scale => 2, :default => 0.0, :null => false
    t.decimal  "order_discount_amount",                 :precision => 8, :scale => 2, :default => 0.0, :null => false
    t.decimal  "sales_tax",                             :precision => 8, :scale => 2, :default => 0.0, :null => false
    t.decimal  "shipping_and_handling",                 :precision => 8, :scale => 2, :default => 0.0, :null => false
    t.decimal  "order_total",                           :precision => 8, :scale => 2, :default => 0.0, :null => false
    t.decimal  "freight_charge",                        :precision => 8, :scale => 2, :default => 0.0, :null => false
    t.integer  "total_item_detail_count"
    t.datetime "shipment_date"
    t.string   "consumer_po_number",      :limit => 22
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "line_number"
  end

  create_table "asn_shipping_method_codes", :force => true do |t|
    t.string   "code",                   :limit => 2
    t.string   "name"
    t.string   "big_bisac_code_sent_in"
    t.integer  "po_box_option_id"
    t.string   "address_type"
    t.string   "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "shipping_method_id"
  end

  create_table "asn_slash_codes", :force => true do |t|
    t.string   "code"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "assets", :force => true do |t|
    t.integer  "viewable_id"
    t.string   "viewable_type",           :limit => 50
    t.string   "attachment_content_type"
    t.string   "attachment_file_name"
    t.integer  "attachment_size"
    t.integer  "position"
    t.string   "type",                    :limit => 75
    t.datetime "attachment_updated_at"
    t.integer  "attachment_width"
    t.integer  "attachment_height"
    t.text     "alt"
  end

  add_index "assets", ["viewable_id"], :name => "index_assets_on_viewable_id"
  add_index "assets", ["viewable_type", "type"], :name => "index_assets_on_viewable_type_and_type"

  create_table "calculators", :force => true do |t|
    t.string   "type"
    t.integer  "calculable_id",   :null => false
    t.string   "calculable_type", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "cdf_binding_codes", :force => true do |t|
    t.string   "code",       :limit => 1
    t.string   "name",       :limit => 20
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "cdf_import_exception_logs", :force => true do |t|
    t.string   "event"
    t.string   "file_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "cdf_invoice_detail_totals", :force => true do |t|
    t.string   "record_code",                :limit => 2
    t.string   "sequence_number",            :limit => 5
    t.integer  "invoice_number"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "cdf_invoice_header_id"
    t.string   "title",                      :limit => 16
    t.integer  "order_id"
    t.integer  "line_item_id"
    t.integer  "cdf_invoice_isbn_detail_id"
    t.integer  "cdf_invoice_ean_detail_id"
    t.integer  "line_number"
  end

  create_table "cdf_invoice_ean_details", :force => true do |t|
    t.string   "record_code",           :limit => 2
    t.string   "sequence_number",       :limit => 5
    t.integer  "invoice_number"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "cdf_invoice_header_id"
    t.string   "ean_shipped",           :limit => 14
    t.integer  "line_number"
  end

  create_table "cdf_invoice_file_trailers", :force => true do |t|
    t.string   "record_code",         :limit => 2
    t.string   "sequence_number",     :limit => 5
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "total_titles"
    t.integer  "total_invoices"
    t.integer  "total_units"
    t.integer  "cdf_invoice_file_id"
    t.integer  "line_number"
  end

  create_table "cdf_invoice_files", :force => true do |t|
    t.string   "record_code",      :limit => 2
    t.string   "sequence_number",  :limit => 5
    t.integer  "ingram_san"
    t.string   "file_source",      :limit => 13
    t.datetime "creation_date"
    t.string   "ingram_file_name", :limit => 22
    t.string   "file_name"
    t.datetime "imported_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "parent_id"
    t.integer  "line_number"
  end

  create_table "cdf_invoice_freight_and_fees", :force => true do |t|
    t.string   "record_code",                 :limit => 2
    t.string   "sequence_number",             :limit => 5
    t.integer  "invoice_number"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "cdf_invoice_header_id"
    t.string   "tracking_number"
    t.decimal  "net_price",                                :default => 0.0, :null => false
    t.decimal  "shipping",                                 :default => 0.0, :null => false
    t.decimal  "handling",                                 :default => 0.0, :null => false
    t.decimal  "gift_wrap",                                :default => 0.0, :null => false
    t.decimal  "amount_due",                               :default => 0.0, :null => false
    t.integer  "line_number"
    t.integer  "cdf_invoice_detail_total_id"
    t.integer  "order_id"
  end

  create_table "cdf_invoice_headers", :force => true do |t|
    t.string   "record_code",               :limit => 2
    t.string   "sequence_number",           :limit => 5
    t.integer  "invoice_number"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "cdf_invoice_file_id"
    t.integer  "company_account_id_number"
    t.integer  "warehouse_san"
    t.datetime "invoice_date"
    t.integer  "line_number"
  end

  create_table "cdf_invoice_isbn_details", :force => true do |t|
    t.string   "record_code",           :limit => 2
    t.string   "sequence_number",       :limit => 5
    t.integer  "invoice_number"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "cdf_invoice_header_id"
    t.string   "isbn_10_shipped"
    t.integer  "quantity_shipped"
    t.decimal  "ingram_list_price",                  :default => 0.0, :null => false
    t.decimal  "discount",                           :default => 0.0, :null => false
    t.decimal  "net_price",                          :default => 0.0, :null => false
    t.datetime "metered_date"
    t.integer  "line_number"
  end

  create_table "cdf_invoice_totals", :force => true do |t|
    t.string   "record_code",           :limit => 2
    t.string   "sequence_number",       :limit => 5
    t.integer  "invoice_number"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "cdf_invoice_header_id"
    t.integer  "invoice_record_count"
    t.integer  "number_of_titles"
    t.integer  "total_number_of_units"
    t.integer  "total_invoice_weight"
    t.integer  "line_number"
    t.string   "bill_of_lading_number"
  end

  create_table "cdf_invoice_trailers", :force => true do |t|
    t.string   "record_code",           :limit => 2
    t.string   "sequence_number",       :limit => 5
    t.integer  "invoice_number"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "cdf_invoice_header_id"
    t.decimal  "total_net_price",                    :default => 0.0, :null => false
    t.decimal  "total_shipping",                     :default => 0.0, :null => false
    t.decimal  "total_handling",                     :default => 0.0, :null => false
    t.decimal  "total_gift_wrap",                    :default => 0.0, :null => false
    t.decimal  "total_invoice",                      :default => 0.0, :null => false
    t.integer  "line_number"
  end

  create_table "comment_types", :force => true do |t|
    t.string   "name"
    t.string   "applies_to"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "comments", :force => true do |t|
    t.string   "title",            :limit => 50, :default => ""
    t.text     "comment",                        :default => ""
    t.integer  "commentable_id"
    t.string   "commentable_type"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "comment_type_id"
  end

  add_index "comments", ["commentable_id"], :name => "index_comments_on_commentable_id"
  add_index "comments", ["commentable_type"], :name => "index_comments_on_commentable_type"
  add_index "comments", ["user_id"], :name => "index_comments_on_user_id"

  create_table "configurations", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type",       :limit => 50
  end

  add_index "configurations", ["name", "type"], :name => "index_configurations_on_name_and_type"

  create_table "countries", :force => true do |t|
    t.string  "iso_name"
    t.string  "iso"
    t.string  "name"
    t.string  "iso3"
    t.integer "numcode"
  end

  create_table "creditcards", :force => true do |t|
    t.string   "month"
    t.string   "year"
    t.string   "cc_type"
    t.string   "last_digits"
    t.string   "first_name"
    t.string   "last_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "start_month"
    t.string   "start_year"
    t.string   "issue_number"
    t.integer  "address_id"
    t.string   "gateway_customer_profile_id"
    t.string   "gateway_payment_profile_id"
  end

  create_table "dc_codes", :force => true do |t|
    t.string   "po_dc_code",  :limit => 1
    t.string   "poa_dc_code", :limit => 1
    t.string   "asn_dc_code", :limit => 2
    t.string   "inv_dc_san",  :limit => 10
    t.string   "dc_name",     :limit => 50
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "gateways", :force => true do |t|
    t.string   "type"
    t.string   "name"
    t.text     "description"
    t.boolean  "active",      :default => true
    t.string   "environment", :default => "development"
    t.string   "server",      :default => "test"
    t.boolean  "test_mode",   :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ingram_stock_files", :force => true do |t|
    t.string   "record_code",        :limit => 2
    t.integer  "parent_id"
    t.string   "file_name"
    t.datetime "imported_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "downloaded_at"
    t.integer  "file_size"
    t.date     "file_date"
    t.datetime "import_queued_at"
    t.datetime "download_queued_at"
    t.string   "import_stats"
  end

  create_table "inventory_units", :force => true do |t|
    t.integer  "variant_id"
    t.integer  "order_id"
    t.string   "state"
    t.integer  "lock_version",            :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "shipment_id"
    t.integer  "return_authorization_id"
    t.integer  "asn_shipment_detail_id"
  end

  add_index "inventory_units", ["order_id"], :name => "index_inventory_units_on_order_id"
  add_index "inventory_units", ["shipment_id"], :name => "index_inventory_units_on_shipment_id"
  add_index "inventory_units", ["variant_id"], :name => "index_inventory_units_on_variant_id"

  create_table "line_items", :force => true do |t|
    t.integer  "order_id"
    t.integer  "variant_id"
    t.integer  "quantity",                                 :null => false
    t.decimal  "price",      :precision => 8, :scale => 2, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "line_items", ["order_id"], :name => "index_line_items_on_order_id"
  add_index "line_items", ["variant_id"], :name => "index_line_items_on_variant_id"

  create_table "log_entries", :force => true do |t|
    t.integer  "source_id"
    t.string   "source_type"
    t.text     "details"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "mail_methods", :force => true do |t|
    t.string   "environment"
    t.boolean  "active",      :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "option_types", :force => true do |t|
    t.string   "name",         :limit => 100
    t.string   "presentation", :limit => 100
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "position",                    :default => 0, :null => false
  end

  create_table "option_types_prototypes", :id => false, :force => true do |t|
    t.integer "prototype_id"
    t.integer "option_type_id"
  end

  create_table "option_values", :force => true do |t|
    t.integer  "option_type_id"
    t.string   "name"
    t.integer  "position"
    t.string   "presentation"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "option_values_variants", :id => false, :force => true do |t|
    t.integer "variant_id"
    t.integer "option_value_id"
  end

  add_index "option_values_variants", ["variant_id", "option_value_id"], :name => "index_option_values_variants_on_variant_id_and_option_value_id"
  add_index "option_values_variants", ["variant_id"], :name => "index_option_values_variants_on_variant_id"

  create_table "orders", :force => true do |t|
    t.integer  "user_id"
    t.string   "number",               :limit => 15
    t.decimal  "item_total",                                                       :default => 0.0, :null => false
    t.decimal  "total",                                                            :default => 0.0, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "state"
    t.decimal  "adjustment_total",                                                 :default => 0.0, :null => false
    t.decimal  "credit_total",                                                     :default => 0.0, :null => false
    t.datetime "completed_at"
    t.integer  "bill_address_id"
    t.integer  "ship_address_id"
    t.decimal  "payment_total",                      :precision => 8, :scale => 2, :default => 0.0
    t.integer  "shipping_method_id"
    t.string   "shipment_state"
    t.string   "payment_state"
    t.string   "email"
    t.text     "special_instructions"
    t.integer  "po_file_id"
    t.string   "order_type"
    t.string   "test_description"
    t.integer  "dc_code_id"
    t.string   "split_shipment_type"
    t.integer  "parent_id"
    t.integer  "affiliate_id"
  end

  add_index "orders", ["number"], :name => "index_orders_on_number"

  create_table "pages", :force => true do |t|
    t.string   "title"
    t.text     "body"
    t.string   "permalink"
    t.boolean  "published"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "meta_keywords"
    t.string   "meta_description"
  end

  create_table "payment_methods", :force => true do |t|
    t.string   "type"
    t.string   "name"
    t.text     "description"
    t.boolean  "active",      :default => true
    t.string   "environment", :default => "development"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.string   "display_on"
  end

  create_table "payments", :force => true do |t|
    t.integer  "order_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "amount",            :default => 0.0, :null => false
    t.integer  "source_id"
    t.string   "source_type"
    t.integer  "payment_method_id"
    t.string   "state"
    t.string   "response_code"
    t.string   "avs_response"
  end

  create_table "paypal_accounts", :force => true do |t|
    t.string "email"
    t.string "payer_id"
    t.string "payer_country"
    t.string "payer_status"
  end

  create_table "pending_promotions", :force => true do |t|
    t.integer "user_id"
    t.integer "promotion_id"
  end

  add_index "pending_promotions", ["promotion_id"], :name => "index_pending_promotions_on_promotion_id"
  add_index "pending_promotions", ["user_id"], :name => "index_pending_promotions_on_user_id"

  create_table "po_box_options", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "po_files", :force => true do |t|
    t.string   "file_name",    :limit => 22
    t.datetime "submitted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "po_statuses", :force => true do |t|
    t.integer  "code"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "po_types", :force => true do |t|
    t.integer  "code"
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "poa_additional_details", :force => true do |t|
    t.string   "record_code",              :limit => 2
    t.string   "sequence_number",          :limit => 5
    t.string   "po_number",                :limit => 22
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "poa_order_header_id"
    t.datetime "availability_date"
    t.string   "dc_inventory_information", :limit => 40
    t.integer  "poa_line_item_id"
  end

  create_table "poa_address_lines", :force => true do |t|
    t.string   "record_code",            :limit => 2
    t.string   "sequence_number",        :limit => 5
    t.string   "po_number",              :limit => 22
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "poa_order_header_id"
    t.string   "recipient_address_line", :limit => 35
  end

  create_table "poa_city_state_zips", :force => true do |t|
    t.string   "record_code",              :limit => 2
    t.string   "sequence_number",          :limit => 5
    t.string   "po_number",                :limit => 22
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "poa_order_header_id"
    t.string   "recipient_city",           :limit => 25
    t.integer  "state_id"
    t.string   "recipient_state_province", :limit => 3
    t.string   "zip_postal_code",          :limit => 11
    t.integer  "country_id"
  end

  create_table "poa_file_control_totals", :force => true do |t|
    t.string  "record_code",              :limit => 2
    t.string  "sequence_number",          :limit => 5
    t.integer "poa_file_id"
    t.integer "total_line_items_in_file"
    t.integer "total_pos_acknowledged"
    t.integer "total_units_acknowledged"
    t.integer "record_count_01"
    t.integer "record_count_02"
    t.integer "record_count_03"
    t.integer "record_count_04"
    t.integer "record_count_05"
    t.integer "record_count_06"
  end

  create_table "poa_files", :force => true do |t|
    t.string   "record_code",             :limit => 2
    t.string   "sequence_number",         :limit => 5
    t.string   "file_source_san",         :limit => 7
    t.string   "file_source_name",        :limit => 13
    t.datetime "poa_creation_date"
    t.string   "electronic_control_unit", :limit => 5
    t.string   "file_name",               :limit => 17
    t.string   "format_version",          :limit => 3
    t.string   "destination_san",         :limit => 7
    t.integer  "poa_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "imported_at"
    t.integer  "po_file_id"
    t.integer  "parent_id"
  end

  create_table "poa_item_number_price_records", :force => true do |t|
    t.string   "record_code",           :limit => 2
    t.string   "sequence_number",       :limit => 5
    t.string   "po_number",             :limit => 22
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "poa_order_header_id"
    t.decimal  "net_price",                           :precision => 8, :scale => 2
    t.string   "item_number_type",      :limit => 2
    t.decimal  "discounted_list_price",               :precision => 8, :scale => 2
    t.integer  "total_line_order_qty"
    t.integer  "poa_line_item_id"
  end

  create_table "poa_line_item_pub_records", :force => true do |t|
    t.string   "record_code",                         :limit => 2
    t.string   "sequence_number",                     :limit => 5
    t.string   "po_number",                           :limit => 22
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "poa_order_header_id"
    t.string   "publisher_name",                      :limit => 20
    t.datetime "publication_release_date"
    t.string   "original_seq_number",                 :limit => 5
    t.string   "total_qty_predicted_to_ship_primary", :limit => 7
    t.integer  "poa_line_item_id"
  end

  create_table "poa_line_item_title_records", :force => true do |t|
    t.string   "record_code",         :limit => 2
    t.string   "sequence_number",     :limit => 5
    t.string   "po_number",           :limit => 22
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "poa_order_header_id"
    t.string   "title",               :limit => 30
    t.string   "author",              :limit => 20
    t.integer  "cdf_binding_code_id"
    t.integer  "poa_line_item_id"
  end

  create_table "poa_line_items", :force => true do |t|
    t.string   "record_code",         :limit => 2
    t.string   "sequence_number",     :limit => 5
    t.string   "po_number",           :limit => 22
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "poa_order_header_id"
    t.string   "line_item_po_number", :limit => 10
    t.string   "item_number",         :limit => 20
    t.integer  "poa_status_id"
    t.integer  "dc_code_id"
    t.integer  "line_item_id"
  end

  create_table "poa_order_control_totals", :force => true do |t|
    t.string  "record_code",              :limit => 2
    t.string  "sequence_number",          :limit => 5
    t.integer "poa_order_header_id"
    t.integer "record_count"
    t.integer "total_line_items_in_file"
    t.integer "total_units_acknowledged"
  end

  create_table "poa_order_headers", :force => true do |t|
    t.string   "record_code",                :limit => 2
    t.string   "sequence_number",            :limit => 5
    t.string   "toc",                        :limit => 13
    t.string   "po_number",                  :limit => 22
    t.string   "icg_ship_to_account_number", :limit => 7
    t.string   "icg_san",                    :limit => 7
    t.integer  "po_status_id"
    t.integer  "poa_file_id"
    t.datetime "acknowledgement_date"
    t.datetime "po_date"
    t.datetime "po_cancellation_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "order_id"
  end

  create_table "poa_ship_to_names", :force => true do |t|
    t.string   "record_code",         :limit => 2
    t.string   "sequence_number",     :limit => 5
    t.string   "po_number",           :limit => 22
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "poa_order_header_id"
    t.string   "recipient_name",      :limit => 35
  end

  create_table "poa_statuses", :force => true do |t|
    t.string   "code"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "poa_types", :force => true do |t|
    t.integer  "code"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "poa_vendor_records", :force => true do |t|
    t.string   "record_code",         :limit => 2
    t.string   "sequence_number",     :limit => 5
    t.string   "po_number",           :limit => 22
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "vendor_message",      :limit => 50
    t.integer  "poa_order_header_id"
  end

  create_table "preferences", :force => true do |t|
    t.string   "name",       :limit => 100, :null => false
    t.integer  "owner_id",   :limit => 30,  :null => false
    t.string   "owner_type", :limit => 50,  :null => false
    t.integer  "group_id"
    t.string   "group_type", :limit => 50
    t.text     "value",      :limit => 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "preferences", ["owner_id", "owner_type", "name", "group_id", "group_type"], :name => "ix_prefs_on_owner_attr_pref", :unique => true

  create_table "product_groups", :force => true do |t|
    t.string "name"
    t.string "permalink"
    t.string "order"
  end

  add_index "product_groups", ["name"], :name => "index_product_groups_on_name"
  add_index "product_groups", ["permalink"], :name => "index_product_groups_on_permalink"

  create_table "product_groups_products", :id => false, :force => true do |t|
    t.integer "product_id"
    t.integer "product_group_id"
  end

  create_table "product_option_types", :force => true do |t|
    t.integer  "product_id"
    t.integer  "option_type_id"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "product_properties", :force => true do |t|
    t.integer  "product_id"
    t.integer  "property_id"
    t.string   "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "product_properties", ["product_id"], :name => "index_product_properties_on_product_id"

  create_table "product_scopes", :force => true do |t|
    t.integer "product_group_id"
    t.string  "name"
    t.text    "arguments"
  end

  add_index "product_scopes", ["name"], :name => "index_product_scopes_on_name"
  add_index "product_scopes", ["product_group_id"], :name => "index_product_scopes_on_product_group_id"

  create_table "products", :force => true do |t|
    t.string   "name",                 :default => "", :null => false
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "permalink"
    t.datetime "available_on"
    t.integer  "tax_category_id"
    t.integer  "shipping_category_id"
    t.datetime "deleted_at"
    t.string   "meta_description"
    t.string   "meta_keywords"
    t.integer  "count_on_hand",        :default => 0,  :null => false
    t.string   "ingram_product_type"
    t.string   "availability_status"
    t.string   "publisher_status"
    t.datetime "ingram_updated_at"
    t.datetime "google_books_update"
    t.string   "subtitle"
    t.string   "publisher"
    t.datetime "published_date"
    t.integer  "page_count"
    t.string   "book_authors"
    t.string   "thumbnail_google_url"
    t.text     "raw_biblio_info"
  end

  add_index "products", ["available_on"], :name => "index_products_on_available_on"
  add_index "products", ["deleted_at", "name"], :name => "deleted_at_and_name"
  add_index "products", ["deleted_at"], :name => "index_products_on_deleted_at"
  add_index "products", ["name"], :name => "index_products_on_name"
  add_index "products", ["permalink"], :name => "index_products_on_permalink"

  create_table "products_promotion_rules", :id => false, :force => true do |t|
    t.integer "product_id"
    t.integer "promotion_rule_id"
  end

  add_index "products_promotion_rules", ["product_id"], :name => "index_products_promotion_rules_on_product_id"
  add_index "products_promotion_rules", ["promotion_rule_id"], :name => "index_products_promotion_rules_on_promotion_rule_id"

  create_table "products_taxons", :id => false, :force => true do |t|
    t.integer "product_id"
    t.integer "taxon_id"
  end

  add_index "products_taxons", ["product_id"], :name => "index_products_taxons_on_product_id"
  add_index "products_taxons", ["taxon_id"], :name => "index_products_taxons_on_taxon_id"

  create_table "promotion_action_line_items", :force => true do |t|
    t.integer "promotion_action_id"
    t.integer "variant_id"
    t.integer "quantity",            :default => 1
  end

  create_table "promotion_actions", :force => true do |t|
    t.integer "activator_id"
    t.integer "position"
    t.string  "type"
  end

  create_table "promotion_rules", :force => true do |t|
    t.integer  "activator_id"
    t.integer  "user_id"
    t.integer  "product_group_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type"
  end

  add_index "promotion_rules", ["product_group_id"], :name => "index_promotion_rules_on_product_group_id"
  add_index "promotion_rules", ["user_id"], :name => "index_promotion_rules_on_user_id"

  create_table "promotion_rules_users", :id => false, :force => true do |t|
    t.integer "user_id"
    t.integer "promotion_rule_id"
  end

  add_index "promotion_rules_users", ["promotion_rule_id"], :name => "index_promotion_rules_users_on_promotion_rule_id"
  add_index "promotion_rules_users", ["user_id"], :name => "index_promotion_rules_users_on_user_id"

  create_table "properties", :force => true do |t|
    t.string   "name"
    t.string   "presentation", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "properties_prototypes", :id => false, :force => true do |t|
    t.integer "prototype_id"
    t.integer "property_id"
  end

  create_table "prototypes", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "return_authorizations", :force => true do |t|
    t.string   "number"
    t.decimal  "amount",     :precision => 8, :scale => 2, :default => 0.0, :null => false
    t.integer  "order_id"
    t.text     "reason"
    t.string   "state"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles", :force => true do |t|
    t.string "name"
  end

  create_table "roles_users", :id => false, :force => true do |t|
    t.integer "role_id"
    t.integer "user_id"
  end

  add_index "roles_users", ["role_id"], :name => "index_roles_users_on_role_id"
  add_index "roles_users", ["user_id"], :name => "index_roles_users_on_user_id"

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "shipments", :force => true do |t|
    t.integer  "order_id"
    t.integer  "shipping_method_id"
    t.string   "tracking"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "number"
    t.decimal  "cost",               :precision => 8, :scale => 2
    t.datetime "shipped_at"
    t.integer  "address_id"
    t.string   "state"
    t.integer  "parent_id"
  end

  add_index "shipments", ["number"], :name => "index_shipments_on_number"

  create_table "shipping_categories", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "shipping_methods", :force => true do |t|
    t.integer  "zone_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "display_on"
    t.string   "environment"
  end

  create_table "state_events", :force => true do |t|
    t.integer  "stateful_id"
    t.integer  "user_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "previous_state"
    t.string   "stateful_type"
    t.string   "next_state"
  end

  create_table "states", :force => true do |t|
    t.string  "name"
    t.string  "abbr"
    t.integer "country_id"
  end

  create_table "tax_categories", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_default",  :default => false
  end

  create_table "tax_rates", :force => true do |t|
    t.integer  "zone_id"
    t.decimal  "amount",          :precision => 8, :scale => 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "tax_category_id"
  end

  create_table "taxonomies", :force => true do |t|
    t.string   "name",       :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "taxons", :force => true do |t|
    t.integer  "taxonomy_id",                      :null => false
    t.integer  "parent_id"
    t.integer  "position",          :default => 0
    t.string   "name",                             :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "permalink"
    t.integer  "lft"
    t.integer  "rgt"
    t.string   "icon_file_name"
    t.string   "icon_content_type"
    t.integer  "icon_file_size"
    t.datetime "icon_updated_at"
    t.text     "description"
  end

  add_index "taxons", ["parent_id"], :name => "index_taxons_on_parent_id"
  add_index "taxons", ["permalink"], :name => "index_taxons_on_permalink"
  add_index "taxons", ["taxonomy_id"], :name => "index_taxons_on_taxonomy_id"

  create_table "tokenized_permissions", :force => true do |t|
    t.integer  "permissable_id"
    t.string   "permissable_type"
    t.string   "token"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tokenized_permissions", ["permissable_id", "permissable_type"], :name => "index_tokenized_name_and_type"

  create_table "trackers", :force => true do |t|
    t.string   "environment"
    t.string   "analytics_id"
    t.boolean  "active",       :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "email"
    t.string   "encrypted_password",   :limit => 128
    t.string   "password_salt",        :limit => 128
    t.string   "remember_token"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "persistence_token"
    t.string   "reset_password_token"
    t.string   "perishable_token"
    t.integer  "sign_in_count",                       :default => 0, :null => false
    t.integer  "failed_attempts",                     :default => 0, :null => false
    t.datetime "last_request_at"
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "login"
    t.integer  "ship_address_id"
    t.integer  "bill_address_id"
    t.string   "authentication_token"
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.datetime "remember_created_at"
    t.integer  "affiliate_id"
  end

  add_index "users", ["persistence_token"], :name => "index_users_on_persistence_token"

  create_table "variants", :force => true do |t|
    t.integer  "product_id"
    t.string   "sku",                                         :default => "",    :null => false
    t.decimal  "price",         :precision => 8, :scale => 2,                    :null => false
    t.decimal  "weight",        :precision => 8, :scale => 2
    t.decimal  "height",        :precision => 8, :scale => 2
    t.decimal  "width",         :precision => 8, :scale => 2
    t.decimal  "depth",         :precision => 8, :scale => 2
    t.datetime "deleted_at"
    t.boolean  "is_master",                                   :default => false
    t.integer  "count_on_hand",                               :default => 0,     :null => false
    t.decimal  "cost_price",    :precision => 8, :scale => 2
    t.integer  "position"
  end

  add_index "variants", ["deleted_at"], :name => "index_variants_on_deleted_at"
  add_index "variants", ["is_master"], :name => "index_variants_on_is_master"
  add_index "variants", ["product_id"], :name => "index_variants_on_product_id"
  add_index "variants", ["sku"], :name => "index_variants_on_sku"

  create_table "zone_members", :force => true do |t|
    t.integer  "zone_id"
    t.integer  "zoneable_id"
    t.string   "zoneable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "zones", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
