Admin::ProductsController.class_eval do
  before_filter :set_product_types, :only => [:edit]

  def set_product_types
    arrays_hash = Product.setup_dropdowns
    @types_array = arrays_hash[:types]
    @available_array = arrays_hash[:available]
    @status_array = arrays_hash[:status]
  end
end