class AddIndexesOnProductsAndVariants < ActiveRecord::Migration
  def change
    add_index :variants, :deleted_at
    add_index :variants, :is_master
  end
end
