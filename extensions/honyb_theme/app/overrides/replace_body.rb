Deface::Override.new(:virtual_path => %q{layouts/spree_application},
                     :name => %q{replace_body},
                     :replace => %q{[data-hook='body']},
                     :closing_selector => %q{},
                     :template => %q{overrides/layouts/spree_application},
:original => %q{<!DOCTYPE HTML>
<html>
  <head data-hook="inside_head">
    <%= render 'shared/head' %>
  </head>
  <body class="<%= body_class %>" id="<%= @body_id || 'default' %>" data-hook="body">
    <div id="header" data-hook>
      <ul id="nav-bar" data-hook>
        <%= render 'shared/nav_bar' %>
      </ul>
      <div id="logo" data-hook>
        <%= logo %>
      </div>
    </div>

    <div id="wrapper" data-hook>
      <% if content_for?(:sidebar) %>
        <div id="sidebar" data-hook>
          <%= yield :sidebar %>
        </div>
      <% end %>

      <div id="content" data-hook>
        <%= breadcrumbs(@taxon) %>
        <%= flash_messages %>
        <%= yield %>
      </div>
    </div>

    <div id="footer" data-hook>
      <div id="footer-left" data-hook>
        <p><%= t(:powered_by) %> <%= link_to 'Spree', 'http://spreecommerce.com/' %></p>
      </div>
      <div id="footer-right" data-hook></div>
    </div>
    <%= render 'shared/google_analytics' %>
  </body>
</html>
})

