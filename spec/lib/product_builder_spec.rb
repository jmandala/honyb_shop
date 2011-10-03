require_relative '../spec_helper'

describe Cdf::ProductBuilder do

  it "should create a new in-stock product" do
    product = Cdf::ProductBuilder.new.next_product!
    product.should_not == nil
    product.has_stock?.should == true
    product.on_hand.should > 0
    product.master.in_stock?.should == true
    product.master.on_backorder.should == 0
  end

  it "should create new in stock products with new skus" do
    pb = Cdf::ProductBuilder.new

    pb.sku.each_key do |key|
      2.times do
        pb.sku[key].each do |isbn|
          isbn.should == pb.next_sku(key)
        end
      end
    end
  end

end