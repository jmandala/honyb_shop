class AddMultiIndexOnProducts < ActiveRecord::Migration
  def change
    add_index :products, :deleted_at_and_name, [:deleted_at, :name]
  end
end
