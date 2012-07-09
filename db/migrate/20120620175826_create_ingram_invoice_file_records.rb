class CreateIngramInvoiceFileRecords < ActiveRecord::Migration
  def up
    create_table 'ingram_stock_files', :force => true do |t|
      t.string :record_code, :limit => 2
      t.integer :parent_id
      t.string :file_name
      t.datetime :imported_at
      t.timestamps
    end
  end

  def down
    drop_table 'ingram_stock_files'
  end
end
