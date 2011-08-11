class AddPoaLineItemToRecords < ActiveRecord::Migration
  def self.up
    add_column :poa_line_item_title_records, :poa_line_item_id, :integer
    add_column :poa_line_item_pub_records, :poa_line_item_id, :integer
  end

  def self.down
    remove_column :poa_line_item_title_records, :poa_line_item_id
    remove_column :poa_line_item_pub_records, :poa_line_item_id
  end
end
