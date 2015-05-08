require 'spec_helper'

describe 'product' do

  let(:product) { Product.new }

  it "should specify the correct SKU TYPE" do
    product.sku_type.should == 'EN'
  end

  it "should run the class method" do
    Product.spec_test.should == true
  end

  it "should get correct bibliographical info from Google Books" do
    product.master = Variant.new(:sku => "9780689843587")
    product.images.size.should == 0
    product.get_biblio_data!

    product.name.should == "The War Within"
    product.subtitle.should == "A Novel of the Civil War"
    product.description.should == "Holly Springs, Mississippi, 1862 Hannah Green can't believe what happens to her family after the war breaks out. First, her sister Joanna falls in love with a Union soldier -- an enemy. Next, the same soldier tells Hannah and her family about General Grant's General Order #11, which commands all Jews to evacuate the territory for violating trade regulations. The Greens escape from Holly Springs just before their home is destroyed. They lose everything -- even their slaves, when Lincoln declares them free. Now, because she is Jewish, Hannah cannot go home to Mississippi -- a Confederate state that's dear to her heart. Confusion sets in. Who is on her side, and whose side does she want to be on?"
    product.page_count.should == 160
    product.publisher.should == "Aladdin"
    product.published_date.strftime("%Y-%m-%d").to_s.should == Date.parse("2002-09-01").to_s
    product.images.size.should == 1
    product.book_authors.should == "Carol Matas"
    product.raw_biblio_info.should_not == nil
    product.raw_biblio_info["volumeInfo"]["title"].should == product.name
    product.google_books_update.should_not == nil
  end


end
