class RenameHonybIdToAffiliateKey < ActiveRecord::Migration
  def up
    rename_column :affiliates, :honyb_id, :affiliate_key
  end

  def down
    rename_column :affiliates, :affiliate_key, :honyb_id
  end
end
