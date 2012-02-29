require_relative "../spec_helper"

describe 'user_decorator' do

  let(:product) { Product.new }
  
  it "should specify the correct SKU TYPE" do
    product.sku_type.should == 'EN'
  end
  
  it "should run the class method" do
    Product.spec_test.should == true
  end
  
  
end
