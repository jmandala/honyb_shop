class AddVersionsToImportFiles < ActiveRecord::Migration
  def self.up
    add_column :asn_files, :parent_id, :integer
    add_column :cdf_invoice_files, :parent_id, :integer
  end

  def self.down
    remove_column :asn_files, :parent_id, :integer
    remove_column :cdf_invoice_files, :parent_id, :integer
  end
end
