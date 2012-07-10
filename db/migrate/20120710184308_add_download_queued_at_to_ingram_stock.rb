class AddDownloadQueuedAtToIngramStock < ActiveRecord::Migration
  def self.up
    add_column :ingram_stock_files, :download_queued_at, :timestamp
  end

  def self.down
    remove_column :ingram_stock_files, :download_queued_at
  end
end
