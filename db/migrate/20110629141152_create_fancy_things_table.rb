class CreateFancyThingsTable < ActiveRecord::Migration
  def self.up
    create_table :fancy_things do |t|
      t.string :name
      t.string :description
      t.timestamps
    end
  end

  def self.down
    drop_table :fancy_things
  end
end
