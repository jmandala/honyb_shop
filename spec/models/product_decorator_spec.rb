require 'spec_helper'
require 'ruby-debug'

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
    product.get_biblio_data!

    product.name.should == "The War Within"
    product.subtitle.should == "A Novel of the Civil War"
    product.description.should == "In 1862, after Union forces expel Hannah's family from Holly Springs, Mississippi, because they are Jews, Hannah reexamines her views regarding slavery and the war."
    product.page_count.should == 151
    product.publisher.should == "Aladdin"
    product.published_date.strftime("%Y-%m-%d").to_s.should == Date.parse("2002-09-01").to_s
    product.thumbnail_google_url.should == "http://bks7.books.google.com/books?id=nYRkhAEak-8C&printsec=frontcover&img=1&zoom=1&source=gbs_api"
    product.book_authors.should == "Carol Matas"
    product.google_books_update.should_not == nil
  end
  
  
end
