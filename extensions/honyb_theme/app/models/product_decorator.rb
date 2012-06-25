Product.class_eval do

  #def self.find_by_permalink!(id)
  #  self.where('permalink = ? ', id)
  #end

  def to_json(options = nil)
    ActiveSupport::JSON.encode(self, { :include => [:master, :variants, :taxons, :images, :product_properties, :properties] })
  end
end
