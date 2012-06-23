#noinspection RubyArgCount
ProductsController.class_eval do 

  respond_to :html, :xml, :json
  
  # Returns the product display page searching by permalink or sku, ignoring dashes
  def show
    @product = Product.find_by_permalink(params[:id])
    @product ||= Variant.where("replace(sku, '-', '') = ?", params[:id].no_dashes).first.product
    return unless @product

    @variants = Variant.active.includes([:option_values, :images]).where(:product_id => @product.id)
    @product_properties = ProductProperty.includes(:property).where(:product_id => @product.id)
    @selected_variant = @variants.detect { |v| v.available? }

    referer = request.env['HTTP_REFERER']

    if referer && referer.match(HTTP_REFERER_REGEXP)
      @taxon = Taxon.find_by_permalink($1)
    end

    respond_with(@product)
  end

end
