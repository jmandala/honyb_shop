Admin::ProductsController.class_eval do
  before_filter :set_product_types, :only => [:edit]

  def set_product_types
    @types_array = Product.product_types
  end
end