Deface::Override.new(:virtual_path => %q{orders/_form},
                          :name => %q{replace_cart_detail},
                          :replace => %q{#cart-detail[data-hook]},
                          :text => %q{<table id="cart-detail" data-hook>
  <thead>
    <tr data-hook="cart_items_headers">
      <th class="product-details"><%= t :product_details %></th>
      <th class="quantity"><%= t :quantity %></th>
      <th class="price"><%= t :price %></th>
    </tr>
  </thead>
  <tbody id="line_items" data-hook>
    <%= order_form.fields_for :line_items do |item_form| %>
      <%= render 'line_item', :variant => item_form.object.variant, :line_item => item_form.object, :item_form => item_form %>
    <% end %>
  </tbody>
  <tfoot>
    <tr>
      <td colspan="2" class="subtotal-label"><%= t :subtotal %>:</td>
      <td class="subtotal-value"><%= order_price(@order) %></td>
  </tfoot>
  </table>

})


Deface::Override.new(:virtual_path => %q{orders/edit},
                          :name => %q{replace_cart_heading},
                          :replace => %q{h1:contains('t(:shopping_cart)')},
                          :text => %q{
<%= content_for :banner do %>
  <%= link_to t(:checkout), checkout_path, :class => 'button checkout' %>
  <h1><%= t :my_cart %></h1>
<% end %> },
                          :original => %q{<h1><%= t(:shopping_cart) %></h1>})


Deface::Override.new(:virtual_path => %q{orders/edit},
                          :name => %q{add_cart_js},
                          :insert_before => %q{code[erb-silent]:contains("@body_id = 'cart'" )},
                          :text => %q{
<% content_for :head do %>
  <%= javascript_include_tag '/states' %>
<% end %>
}
)