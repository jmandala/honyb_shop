class AddBookFieldsToProduct < ActiveRecord::Migration
  def up
    add_column :products, :subtitle, :string
    add_column :products, :publisher, :string
    add_column :products, :published_date, :datetime
    add_column :products, :page_count, :integer
    add_column :products, :book_authors, :string
    add_column :products, :thumbnail_google_url, :string
  end

  def down
    remove_column :products, :subtitle
    remove_column :products, :publisher
    remove_column :products, :published_date
    remove_column :products, :page_count
    remove_column :products, :book_authors
    remove_column :products, :thumbnail_google_url
  end
end
