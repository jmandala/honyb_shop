require 'spec_helper'

describe PoFile do

  before(:each) do
    @order = Factory(:order)
    add_line_item @order
    complete_order @order
  end

  context "when creating a purchase order" do
    it "should have proper formatting" do
      po_file = PoFile.generate
      puts po_file.data
    end
  end

end