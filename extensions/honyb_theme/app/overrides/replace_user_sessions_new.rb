Deface::Override.new(:virtual_path => %q{user_sessions/new},
                          :name => %q{replace_user_sessions_new},
                          :replace => %q{#existing-customer},
                          :text => %q{
<% if Rails.application.railties.all.map(&:railtie_name).include? "spree_social" %>
  <%= render 'shared/social_users' %>
<% end %>

<%= render "shared/error_messages", :target => @order %>

<div id="local_login">
  <%= render :template => 'shared/_sign_in_or_sign_up' %>
</div>
})
