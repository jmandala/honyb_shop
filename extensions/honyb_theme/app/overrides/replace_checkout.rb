Deface::Override.new(:virtual_path => %q{checkout/edit},
                     :name => %q{replace_checkout},
                     :replace => %q{#checkout[data-hook]},
                     :closing_selector => %q{},
                     :template => %q{overrides/checkout/edit},
                     :original => %q{<% content_for :head do %>
  <%= javascript_include_tag '/states' %>
<% end %>
<div id="checkout" data-hook>
  <h1><%= t(:checkout) %></h1>
  <%= checkout_progress %>
  <br clear="left" />
  <%= render 'shared/error_messages', :target => @order %>
  <% if @order.state != 'confirm' %>
    <div id="checkout-summary" data-hook="checkout_summary_box">
      <%= render 'summary', :order => @order %>
    </div>
  <% end %>
  <%= form_for @order, :url => update_checkout_path(@order.state), :html => { :id => "checkout_form_#{@order.state}" } do |form| %>
    <%= render @order.state, :form => form %>
    <%= submit_tag nil, :id => 'post-final', :style => 'display:none;' %>
  <% end %>
</div>
})
