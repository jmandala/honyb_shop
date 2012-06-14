Deface::Override.new(:virtual_path => %q{checkout/_delivery},
                          :name => %q{replace_shipping_method},
                          :replace => %q{#shipping_method[data-hook]},
                          :partial => %q{overrides/checkout/delivery},
                          :original => %q{<fieldset id='shipping_method' data-hook>
  <legend><%= t(:shipping_method) %></legend>
  <div class="inner" data-hook="shipping_method_inner">
    <div id="methods">
      <p class="field radios">
        <% @order.rate_hash.each do |shipping_method| %>
          <label>
            <%= radio_button(:order, :shipping_method_id, shipping_method[:id]) %>
            <% if Spree::Config[:shipment_inc_vat] %>
              <%= shipping_method[:name] %> <%= format_price (1 + TaxRate.default) * shipping_method[:cost] %>
            <% else %>
            <%= shipping_method[:name] %> <%= number_to_currency shipping_method[:cost] %>
            <% end %>
          </label><br />
        <% end %>
      </p>
    </div>
    <% if Spree::Config[:shipping_instructions] && @order.rate_hash.present? %>
      <p id="minstrs" data-hook>
        <%= form.label :special_instructions, t(:shipping_instructions) %><br />
        <%= form.text_area :special_instructions, :cols => 40, :rows => 7 %>
      </p>
    <% end %>
  </div>
</fieldset>

<div class="form-buttons" data-hook="buttons">
  <%= submit_tag t(:save_and_continue), :class => 'continue button primary' %>
</div>
})
