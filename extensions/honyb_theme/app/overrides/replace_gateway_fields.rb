Deface::Override.new(:virtual_path => %q{checkout/payment/_gateway},
                          :name => %q{replace_gateway_fields},
                          :replace => %q{[data-hook='card_number']},
                          :partial => %q{overrides/checkout/payment/gateway},
                          :original => %q{<%= image_tag 'creditcards/creditcard.gif', :id => 'creditcard-image' %>
<% param_prefix = "payment_source[#{payment_method.id}]" %>

<p class="field" data-hook="card_number">
  <%= label_tag nil, t(:card_number) %><br />
  <% options_hash = Rails.env.production? ? {:autocomplete => 'off'} : {} %>
  <%= text_field_tag "#{param_prefix}[number]", '', options_hash.merge(:id => 'card_number', :class => 'required', :size => 19, :maxlength => 19) %>
  <span class="req">*</span>
  &nbsp;
  <span id="card_type" style="display:none;">
    ( <span id="looks_like" ><%= t(:card_type_is) %> <span id="type"></span></span>
      <span id="unrecognized"><%= t(:unrecognized_card_type) %></span>
    )
  </span>
</p>
<p class="field" data-hook="card_expiration">
  <%= label_tag nil, t(:expiration) %><br />
  <%= select_month(Date.today, :prefix => param_prefix, :field_name => 'month', :use_month_numbers => true, :class => 'required') %>
  <%= select_year(Date.today, :prefix => param_prefix, :field_name => 'year', :start_year => Date.today.year, :end_year => Date.today.year + 15, :class => 'required') %>
  <span class="req">*</span>
</p>
<p class="field" data-hook="cart_code">
  <%= label_tag nil, t(:card_code) %><br />
  <%= text_field_tag "#{param_prefix}[verification_value]", '', options_hash.merge(:id => 'card_code', :class => 'required', :size => 5) %>
  <span class="req">*</span>
  <a href="/content/cvv" target="_blank" onclick="window.open(this.href,'cvv_info','left=20,top=20,width=500,height=500,toolbar=0,resizable=0,scrollbars=1');return false" data-hook="ccv_link">
    (<%= t(:whats_this) %>)
  </a>
</p>
<%= hidden_field param_prefix, 'first_name', :value => @order.billing_firstname %>
<%= hidden_field param_prefix, 'last_name', :value => @order.billing_lastname %>})
