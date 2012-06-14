#noinspection RubyArgCount
Api::ProductsController.class_eval do
  
  def object_serialization_options
    { :include => [:master, :variants, :taxons, :images, :product_properties ] }
  end
  
end