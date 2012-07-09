class AddInventoryUpdatedToProduct < ActiveRecord::Migration
  def up
    add_column :products, :ingram_updated_at, :datetime
  end

  def down
    remove_column :products, :ingram_updated_at
  end
end
