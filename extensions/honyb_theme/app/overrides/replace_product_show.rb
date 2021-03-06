Deface::Override.new(:virtual_path => %q{products/show},
                          :name => %q{replace_product_show},
                          :replace => %q{[data-hook='product_show']},
                          :closing_selector => %q{},
                          :template => %q{overrides/products/show},
                          :original => %q{<div data-hook="product_show">
  <% @body_id = 'product-details' %>
  <h1><%= accurate_title %></h1>

  <div id="product-images" data-hook="product_images">
    <div id="main-image" data-hook>
      <%= render 'image' %>
    </div>
    <div id="thumbnails" data-hook>
      <%= render 'thumbnails', :product => @product %>
    </div>
  </div>

  <div id="cart-form" data-hook="cart_form">
    <%= render 'cart_form' %>
  </div>

  <div id="product-description" data-hook="product_description">
    <%= product_description(@product) rescue t(:product_has_no_description) %>
    <div data-hook="product_properties">
      <%= render 'properties' %>
    </div>
  </div>
</div>

},
                          :disabled => false,
                          
                          :sequence => 100)

