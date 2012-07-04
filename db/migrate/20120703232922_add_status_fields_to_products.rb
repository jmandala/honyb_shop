class AddStatusFieldsToProducts < ActiveRecord::Migration
  def up
    add_column :products, :availability_status, :string
    add_column :products, :publisher_status, :string
  end

  def down
    remove_column :products, :availability_status
    remove_column :products, :publisher_status
  end
end
