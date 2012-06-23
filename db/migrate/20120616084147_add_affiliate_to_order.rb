class AddAffiliateToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :affiliate_id, :integer
  end
end
