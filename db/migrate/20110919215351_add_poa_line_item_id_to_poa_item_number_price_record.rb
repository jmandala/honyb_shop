class AddPoaLineItemIdToPoaItemNumberPriceRecord < ActiveRecord::Migration
  def self.up
    add_column :poa_item_number_price_records, :poa_line_item_id, :integer
  end

  def self.down
    remove_column :poa_item_number_price_records, :poa_line_item_id
  end
end
