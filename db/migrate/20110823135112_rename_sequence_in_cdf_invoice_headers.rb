class RenameSequenceInCdfInvoiceHeaders < ActiveRecord::Migration
  def self.up
    rename_column :cdf_invoice_headers, :sequence, :sequence_number    
  end

  def self.down
    rename_column :cdf_invoice_headers, :sequence_number, :sequence    
  end
end
