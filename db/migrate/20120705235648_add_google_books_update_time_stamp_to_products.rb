class AddGoogleBooksUpdateTimeStampToProducts < ActiveRecord::Migration
  def up
    add_column :products, :google_books_update, :datetime
  end

  def down
    remove_column :products, :google_books_update
  end
end
