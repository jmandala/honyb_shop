require_relative '../spec_helper'

describe Cdf::ProductBuilder do
  
  it "should create a new in-stock product" do
    product = Cdf::ProductBuilder.next_in_stock!
    product.should_not == nil
  end
  
  it "should create new in stock products with new skus" do
    sku1 = Cdf::ProductBuilder.next_sku Cdf::ProductBuilder::IN_STOCK
    FactoryGirl.create(:product, :sku => sku1)
    
    sku2 = Cdf::ProductBuilder.next_sku Cdf::ProductBuilder::IN_STOCK
    sku1.should_not == sku2
  end
  
end