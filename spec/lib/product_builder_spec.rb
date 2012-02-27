require_relative '../spec_helper'

describe Cdf::ProductBuilder do

  let(:pb) { Cdf::ProductBuilder.new  }
  
  it "should create a new in-stock product" do
    product = Cdf::ProductBuilder.new.next_product!
    product.should_not == nil
    product.has_stock?.should == true
    product.on_hand.should > 0
    product.master.in_stock?.should == true
    product.master.on_backorder.should == 0
  end

  it "should create new in stock products with new skus" do

    Cdf::ProductBuilder::SKU.each_key do |key|
      2.times do
        Cdf::ProductBuilder::SKU[key].each do |isbn|
          isbn.should == pb.next_sku(key)
        end
      end
    end
  end
  
  it "should create new products with customer skus" do
    product = Cdf::ProductBuilder.create!(:sku => '123abc', :name => 'test123')
    product.sku.should == '123abc'
  end

end