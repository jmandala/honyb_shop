ProductsHelper.module_eval do

  def updated_product_image product
    if !product.images.empty? || product.thumbnail_google_url.nil?
      product_image product
    else
      image_tag product.thumbnail_google_url
    end
  end

  def book_authors_display product
    return "" if product.book_authors.blank?

    return "#{product.book_authors} (Author)"
  end

end