class AddMultiIndexOnProducts < ActiveRecord::Migration
  def change
    add_index :products, [:deleted_at, :name], :deleted_at_and_name
  end
end
