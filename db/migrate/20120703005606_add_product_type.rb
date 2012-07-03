class AddProductType < ActiveRecord::Migration
  def up
    add_column :products, :ingram_product_type, :string
  end

  def down
    remove_column :products, :ingram_product_type
  end
end
