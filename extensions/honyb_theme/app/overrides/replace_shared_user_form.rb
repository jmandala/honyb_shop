 Deface::Override.new(:virtual_path => %q{shared/_user_form},
                          :name => %q{replace_shared_user_form},
                          :replace => %q{#new-customer},
                          :text => %q{<div id="new_customers">
    <h2><%= t :new_customer %></h2>
    <div><%= t :new_customer_message %></div>
    <%= form_for(:user, :url => registration_path(User.new)) do |f| %>
      <%= render 'shared/user_form', :f => f %>
      <div class="actions">
        <button type="submit">Register</button>
      </div>
    <% end %>
  </div>})
