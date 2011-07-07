class CreatePoaOrderHeaders < ActiveRecord::Migration
  def self.up
    create_table :poa_order_headers do |t|
      t.string :record_code, :limit => 2
      t.string :sequence_number, :limit => 5
      t.string :toc, :limit => 13
      t.string :po_number, :limit => 22
      t.string :icg_ship_to_account_number, :limit => 7
      t.string :icg_san, :limit => 7
      t.integer :po_status_id
      t.integer :poa_file_id
      t.integer :po_file_id
      t.datetime :acknowledgement_date
      t.datetime :po_date
      t.datetime :po_cancellation_date
      t.timestamps
    end
  end

  def self.down
    drop_table :poa_order_headers
  end
end
