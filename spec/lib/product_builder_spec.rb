require_relative '../spec_helper'

describe Cdf::ProductBuilder do

  it "should create a new in-stock product" do
    product = Cdf::ProductBuilder.new.next_in_stock!
    product.should_not == nil
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