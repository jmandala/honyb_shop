Deface::Override.new(:virtual_path => %q{checkout/_payment},
                          :name => %q{replace_payment},
                          :replace => %q{#payment[data-hook]},
                          :partial => %q{overrides/checkout/payment/payment},
                          :original => %q{<fieldset id="payment" data-hook>
  <legend><%= t(:payment_information) %></legend>
  <div data-hook="checkout_payment_step">
    <% @order.available_payment_methods.each do |method| %>
    <p>
      <label>
        <%= radio_button_tag "order[payments_attributes][][payment_method_id]", method.id, method == @order.payment_method %>
        <%= t(method.name, :scope => :payment_methods, :default => method.name) %>
      </label>
    </p>
    <% end %>

    <ul id="payment-methods" data-hook>
      <% @order.available_payment_methods.each do |method| %>
        <li id="payment_method_<%= method.id %>" class="<%= 'last' if method == @order.available_payment_methods.last %>" data-hook>
          <fieldset>
            <%= render "checkout/payment/#{method.method_type}", :payment_method => method %>
          </fieldset>
        </li>
      <% end %>
    </ul>
    <br style="clear:both;" />
    <div data-hook="coupon_code_field" data-hook></div>
  </div>
</fieldset>

<hr class="space" />
<div class="form-buttons" data-hook="buttons">
  <%= submit_tag t(:save_and_continue), :class => 'continue button primary' %>
</div>})
