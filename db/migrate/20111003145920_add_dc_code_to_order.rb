class AddDcCodeToOrder < ActiveRecord::Migration
  def self.up
    add_column :orders, :dc_code_id, :integer
  end

  def self.down
    remove_column :orders, :dc_code_id
  end
end
