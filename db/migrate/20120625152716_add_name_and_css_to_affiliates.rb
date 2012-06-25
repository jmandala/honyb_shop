class AddNameAndCssToAffiliates < ActiveRecord::Migration
  def change
    add_column :affiliates, :name, :string
    add_column :affiliates, :why_buy_text, :text
    add_column :affiliates, :css, :text
  end
end
