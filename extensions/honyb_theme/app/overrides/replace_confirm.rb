Deface::Override.new(:virtual_path => %q{checkout/_confirm},
                          :name => %q{replace_confirm},
                          :replace => %q{#order_details[data-hook]},
                          :partial => %q{overrides/checkout/confirm},
                          :original => %q{<fieldset id="order_details" data-hook>
  <div class="clear"></div>
  <legend><%= t(@order.state, :scope => :order_state).titleize %></legend>
  <%= render :partial => 'shared/order_details', :locals => {:order => @order} %>
</fieldset>

<hr />

<div class="form-buttons" data-hook="buttons">
  <%= submit_tag t(:place_order), :class => 'continue button primary' %>
</div>
})
