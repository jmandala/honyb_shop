require_relative '../spec_helper'

describe Cdf::ProductBuilder do
  
  it "should create a new in-stock product" do
    product = Cdf::ProductBuilder.in_stock!
    product.should_not == nil
  end
  
end