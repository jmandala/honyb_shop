Deface::Override.new(:virtual_path => %q{orders/edit},
                     :name => %q{replace_empty_cart},
                     :replace => %q{[data-hook='empty_cart']},
                     :text => %q{<div id="cart-is-empty" data-hook="empty_cart">
    <p><%= t(:your_cart_is_empty) %></p>
    <p><%= link_to t(:continue_shopping), products_path, :class => 'button continue shopping' %></p>
  </div>
},
                     :original => %q{<div data-hook="empty_cart">
    <p><%= t(:your_cart_is_empty) %></p>
    <p><%= link_to t(:continue_shopping), products_path, :class => 'button continue' %></p>
  </div>})
