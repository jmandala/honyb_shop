class AddEnvironmentToShippingMethod < ActiveRecord::Migration
  def self.up
    add_column :shipping_methods, :environment, :string
  end

  def self.down
    remove_column :shipping_methods, :environment
  end
end
