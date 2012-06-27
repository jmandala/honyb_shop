class AddDownloadedFieldToIngramStockFiles < ActiveRecord::Migration
  def self.up
    add_column :ingram_stock_files, :downloaded_at, :timestamp
  end

  def self.down
    remove_column :ingram_stock_files, :downloaded_at
  end
end
