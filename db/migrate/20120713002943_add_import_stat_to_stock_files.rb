class AddImportStatToStockFiles < ActiveRecord::Migration
  def self.up
    add_column :ingram_stock_files, :import_stats, :string
  end

  def self.down
    remove_column :ingram_stock_files, :import_stats
  end
end
