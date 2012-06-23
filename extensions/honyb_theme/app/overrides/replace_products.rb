Deface::Override.new(:virtual_path => %q{shared/_products},
                     :name => %q{replace_products},
                     :replace => %q{#products[data-hook]},
                     :closing_selector => %q{},
                     :text => %q{<% @body_id = 'product-list' %>

<%= content_for :banner do %>
  <h1>Products</h1>
<% end %>

<div class="list" id="products" data-hook>
<% products.each do |product| %>
  <% if Spree::Config[:show_zero_stock_products] || product.has_stock? %>
    <div class="product">
      <div class="image">
        <%= link_to product_image(product), product, :title => product.name %>
      </div>

      <div class="details">
        <div class="prices">
          <span class="price discounted"><%= number_to_currency(product.price * 1.2) %></span>&nbsp;
          <span class="price selling"><%= product_price(product) %></span></div>
        <div><%= link_to 'View More', product_path(product), :class => 'button' %></div>
      </div>
    </div>
  <% end %>
<% end %>
</div>})
