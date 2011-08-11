class AddPoaLineItemToPoaAdditionalDetailRecord < ActiveRecord::Migration
  def self.up
    add_column :poa_additional_details, :poa_line_item_id, :integer
  end

  def self.down
    remove_column :poa_additional_details, :poa_line_item_id
  end
end
