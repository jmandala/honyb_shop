class DeleteProductIdFromPoaLineItems < ActiveRecord::Migration
  def self.up
    remove_column :poa_line_items, :product_id
  end

  def self.down
    add_column :poa_line_items, :product_id, :integer
  end
end
