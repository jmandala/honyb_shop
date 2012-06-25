Deface::Override.new(:virtual_path => %q{orders/_line_item},
                     :name => %q{replace_line_item},
                     :replace => %q{tr},
                     :text => %q{
<%
   # Define product properties
  product_properties = ProductProperty.includes(:property).where(:product_id => variant.product.id)
   if product_properties
     subtitle = product_properties.includes(:property).where('properties.name = "Subtitle"').first
     author = product_properties.includes(:property).where('properties.name = "Author Statement"').first
     product_details = product_properties.includes(:property).where('properties.name = "Product Details"').first
   end
%>
                     
<tr class="cart-line-item <%= cycle('', 'alt') %>">
  <td valign="top" class="product-detail">
    <div class="cart-item-image" data-hook="cart_item_image">
      <% if variant.images.length == 0 %>
      <%= small_image(variant.product) %>
      <% else %>
      <%=  image_tag variant.images.first.attachment.url(:small) %>
      <% end %>
    </div>

    <div class="cart-item-description" data-hook="cart_item_description">
        <div class="title-and-subtitle">
          <div class="title"><%= link_to variant.product.name,  product_path(variant.product) %></div>
          <% if subtitle && !subtitle.value.empty? %>
            <div class="subtitle"><%= subtitle.value %></div>
          <% end %>
        </div>

      <% if author && author.value %>
        <div class="author">
          <%= author.value.html_safe %>
        </div>
      <% end %>

    <div class="unit-price" data-hook="cart_item_price">
      <%= product_price(line_item) %>    
    </div>
    
    </div>
  </td>
    
  <td valign="top" class="quantity" data-hook="cart_item_quantity">
    <%= item_form.text_field :quantity, :size => 3, :class => "line-item-quantity" %>

    <div>    
      <button type="submit" class="update"><%= t :update %></button>
      <%= content_tag :span, :class => :remove do -%>
        <%= t :remove -%>
      <% end -%>
    <div>

   </td>

  <td valign="top" class="cart-item-total" data-hook="cart_item_total">
    <div class="ext-price"><%= format_price(product_price(line_item, :format_as_currency => false) * line_item.quantity) unless line_item.quantity.nil? %></div>
  </td>
</tr>})
