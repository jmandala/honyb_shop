class CreateCdfImportExceptionLogs < ActiveRecord::Migration
  def self.up
    create_table :cdf_import_exception_logs do |t|
      t.string :event
      t.string :file_name

      t.timestamps
    end
  end

  def self.down
    drop_table :cdf_import_exception_logs
  end
end
