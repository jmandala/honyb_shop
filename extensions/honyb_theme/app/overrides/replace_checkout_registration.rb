Deface::Override.new(:virtual_path => %q{checkout/registration},
                          :name => %q{replace_checkout_registration},
                          :replace => %q{#registration},
                          :text => %q{
<%= content_for :banner do %>
  <h1><span class="faint"><%= t :checkout %>:</span> <span class="highlight"><%= t :sign_in %></span</h1>
<% end %>                          

<%= render "shared/error_messages", :target => @order %>

<%= render :template => 'shared/_sign_in_or_sign_up' %>

})
