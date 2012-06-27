class AddDateToStockFiles < ActiveRecord::Migration
  def self.up
    add_column :ingram_stock_files, :file_date, :date
  end

  def self.down
    remove_column :ingram_stock_files, :file_date
    end
end
