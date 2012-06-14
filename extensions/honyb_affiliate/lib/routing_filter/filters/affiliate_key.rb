# This filter extracts the :affiliate_key value from the 
# path and exposes the page parameter as params[:affiliate_key]. When a path is generated
# the filter adds the :affiliate_key to the path accordingly if the :affiliate_key parameter is
# passed to the url helper.
#
#   incoming url: /embed/h-the-affiliate-id/products
#   filtered url: /embed/products
#   params:       params[:affiliate_key] = the-affiliate-id
#
# You can install the filter like this:
#
#   # in config/routes.rb
#   Rails.application.routes.draw do
#     filter :affiliate_key
#   end
#
# To make your named_route helpers or url_for add the embed segment you can use:
#
#   products_path(:affiliate_key => true)
#   url_for(:products, :affiliate_key => true)

module RoutingFilter
  class AffiliateKeyFilter < Filter
    AFFILIATE_KEY_PREFIX = 'h-' unless AffiliateKeyFilter.const_defined? :AFFILIATE_KEY_PREFIX
    AFFILIATE_KEY_SEGMENT = %r(/#{AFFILIATE_KEY_PREFIX}([^/]+)([$/])?) unless AffiliateKeyFilter.const_defined? :AFFILIATE_KEY_SEGMENT
    
    def around_recognize(path, env, &block)
      affiliate_key = extract_segment!(AFFILIATE_KEY_SEGMENT, path)
      
      yield.tap do |params|
        params[:affiliate_key] = affiliate_key if affiliate_key
      end
    end

    def around_generate(params, &block)
      params.delete(:affiliate_key) if Affiliate.current
      yield.tap do |result|
        prepend_segment!(result, affiliate_key_param) if Affiliate.current
      end
    end
    
    def affiliate_key_param
      Affiliate.current.nil? ? '' : "#{AFFILIATE_KEY_PREFIX}#{Affiliate.current.affiliate_key}"
    end
  end
end