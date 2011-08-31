class AddTestDescriptionToOrder < ActiveRecord::Migration
  def self.up
    add_column :orders, :test_description, :string
  end

  def self.down
    remove_column :orders, :test_description
  end
end
