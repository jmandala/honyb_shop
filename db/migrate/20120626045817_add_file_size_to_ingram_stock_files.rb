class AddFileSizeToIngramStockFiles < ActiveRecord::Migration
  def self.up
    add_column :ingram_stock_files, :file_size, :integer
  end

  def self.down
    remove_column :ingram_stock_files, :file_size
    end
end
