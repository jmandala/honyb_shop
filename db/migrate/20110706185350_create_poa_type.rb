class CreatePoaType < ActiveRecord::Migration
  def self.up
    create_table :poa_types do |t|
      t.integer :code
      t.text :description

      t.timestamps
  end

  def self.down
    drop_table :poa_types
  end
  end
end
