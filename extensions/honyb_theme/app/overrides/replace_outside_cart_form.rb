Deface::Override.new(:virtual_path => %q{orders/edit},
                          :name => %q{replace_outside_cart_form},
                          :replace => %q{[data-hook='outside_cart_form']},
                          :closing_selector => %q{},
                          :text => %q{<%= form_for(@order, :url => update_cart_path, :html=>{:id=>'updatecart'}) do |order_form| %>

    <div data-hook="cart_items">
      <%= render :partial => 'form', :locals => {:order_form => order_form} %>
    </div>

    <div class="bottom-checkout">
      <%= link_to t("global.continue_shopping"), products_path, :class => 'continue  shopping' %> 
      <span class="or"><%= t('global.or') %></span>
      <%= link_to t("checkout"), checkout_path, :class => 'button checkout' %>
    </div>

  <% end %>},
                          :disabled => false,
                          :sequence => 100)
