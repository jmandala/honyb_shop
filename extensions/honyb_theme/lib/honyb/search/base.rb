module Honyb::Search

  class Base < Spree::Search::Base
    protected


    # method should return new scope based on base_scope
    def get_products_conditions_for(base_scope, query)
      base_scope.joins(:master).where('products.name LIKE ? OR variants.sku LIKE ?', "%#{query}%", "%#{query}%")
    end

  end
end