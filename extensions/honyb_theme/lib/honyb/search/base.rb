module Honyb::Search

  class Base < Spree::Search::Base
    protected


    # method should return new scope based on base_scope
    def get_products_conditions_for(base_scope, query)
      base_scope.like_any([:name], query.split)      
    end

  end
end