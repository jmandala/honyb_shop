class CreatePoStatuses < ActiveRecord::Migration
  def self.up
    create_table :po_statuses do |t|
      t.integer :code
      t.string :name

      t.timestamps
    end
  end

  def self.down
    drop_table :po_statuses
  end
end
