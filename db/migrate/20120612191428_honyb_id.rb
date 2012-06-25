class HonybId < ActiveRecord::Migration
  def up
    create_table :affiliates do |t|
      t.string :honyb_id, :null => false
      t.timestamps
    end
    add_index :affiliates, :honyb_id, :unique => true, :name => 'honyb_id'
    
  end

  def down
    drop_table :affiliates
  end
end
