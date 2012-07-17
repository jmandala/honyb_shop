class SaveRawBiblioINfo < ActiveRecord::Migration
  def up
    add_column :products, :raw_biblio_info, :text
  end

  def down
    remove_column :products, :raw_biblio_info
  end
end
