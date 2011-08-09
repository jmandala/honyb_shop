class AddVersionsToPoaFile < ActiveRecord::Migration
  def self.up
    add_column :poa_files, :parent_id, :integer
  end

  def self.down
    remove_column :poa_files, :parent_id
  end
end
