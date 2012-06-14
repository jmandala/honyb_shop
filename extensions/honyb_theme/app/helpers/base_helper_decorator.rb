Spree::BaseHelper.class_eval do

  def link_to_cart(text = t('cart'))
    return "" if current_page?(cart_path)
    css_class = nil
    if current_order.nil? or current_order.line_items.empty?
      text = "#{text}: (#{t('empty')})"
      css_class = 'empty'
    else
      text = "#{text}: (#{current_order.item_count}) #{order_price(current_order)}"
      css_class = 'full'
    end
    link_to text, cart_path, :class => css_class
  end

  def embed?
    !params[:embed].nil?
  end

  def embed_class
    embed? ? 'embed' : 'normal'
  end

  def ssl_class
    request.ssl? ? 'ssl' : ''
  end
  
  def body_class
    @body_class ||= ''
    append_class(@body_class, embed_class)
    append_class(@body_class, ssl_class)
    append_class(@body_class, Affiliate.current.honyb_id) if Affiliate.current
    @body_class
  end
  
  private
  
  def append_class(orig, new)
    orig ||= ''
    orig << ' ' if orig.length > 0 && new.length > 0
    orig << new
    orig
  end
  
end
