# The HonybId filter extracts the :honyb_id value from the 
# path and exposes the page parameter as params[:honyb_id]. When a path is generated
# the filter adds the :honyb_id to the path accordingly if the :honyb_id parameter is
# passed to the url helper.
#
#   incoming url: /embed/h-the-affiliate-id/products
#   filtered url: /embed/products
#   params:       params[:honyb_id] = the-affiliate-id
#
# You can install the filter like this:
#
#   # in config/routes.rb
#   Rails.application.routes.draw do
#     filter :honyb_id
#   end
#
# To make your named_route helpers or url_for add the embed segment you can use:
#
#   products_path(:honyb_id => true)
#   url_for(:products, :honyb_id => true)

module RoutingFilter
  class HonybId < Filter
    HONYB_ID_PREFIX = 'h-' unless HonybId.const_defined? :HONYB_ID_PREFIX
    HONYB_ID_SEGMENT = %r(/#{HONYB_ID_PREFIX}([^/]+)([$/])?) unless HonybId.const_defined? :HONYB_ID_SEGMENT
    
    def around_recognize(path, env, &block)
      honyb_id = extract_segment!(HONYB_ID_SEGMENT, path)

      
      yield.tap do |params|
        params[:honyb_id] = honyb_id if honyb_id
      end
    end

    def around_generate(params, &block)
      params.delete(:honyb_id) if Affiliate.current
      yield.tap do |result|
        prepend_segment!(result, honyb_id_param) if Affiliate.current
      end
    end
    
    def honyb_id_param
      Affiliate.current.nil? ? '' : "#{HONYB_ID_PREFIX}#{Affiliate.current.honyb_id}"
    end
  end
end