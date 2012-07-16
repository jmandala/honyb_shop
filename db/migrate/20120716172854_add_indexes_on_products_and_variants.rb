class AddIndexesOnProductsAndVariants < ActiveRecord::Migration
  def change
    rename_index :products, :index_products_on_name, :name
    add_index :variants, :deleted_at
    add_index :variants, :is_master
  end
end
