class AddImportScheduledToStockFiles < ActiveRecord::Migration
  def self.up
    add_column :ingram_stock_files, :import_queued_at, :timestamp
  end

  def self.down
    remove_column :ingram_stock_files, :import_queued_at
  end
end
