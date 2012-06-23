# The Embed filter extracts the "embed" flag from the beginning of the 
# path and exposes the page parameter as params[:embed]. When a path is generated
# the filter adds the "embed" flag to the path accordingly if the :embed parameter is
# passed to the url helper.
#
#   incoming url: /embed/products
#   filtered url: /products
#   params:       params[:embed] = true
#
# You can install the filter like this:
#
#   # in config/routes.rb
#   Rails.application.routes.draw do
#     filter :embed
#   end
#
# To make your named_route helpers or url_for add the embed segment you can use:
#
#   products_path(:embed => true)
#   url_for(:products, :embed => true)

module RoutingFilter
  class Embed < Filter
    EMBED_SEGMENT = %r(^/?(embed)(/)?) unless Embed.const_defined? :EMBED_SEGMENT
    
    def around_recognize(path, env, &block)
      embed = extract_segment!(EMBED_SEGMENT, path)
      
      yield.tap do |params|
        params[:embed] = true if embed
      end
    end

    def around_generate(params, &block)
      embed = params.delete(:embed)
      yield.tap do |result|
        prepend_segment!(result, 'embed') if embed
      end
    end
  end
end