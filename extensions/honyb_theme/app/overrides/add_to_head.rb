Deface::Override.new(:virtual_path => %q{shared/_head},
                          :name => %q{add_to_head},
                          :insert_after => %q{code[erb-loud]:contains('stylesheet_link_tag')},
                          :partial => %{overrides/shared/head},
:original => %q{<title><%= title %></title>
<meta content="text/html; charset=UTF-8" http-equiv="Content-Type" />
<%== meta_data_tags %>
<%= stylesheet_link_tag 'store/all', :media => 'screen' %>
<%= csrf_meta_tags %>
<%= javascript_include_tag 'store/all' %>
<%= yield :head %>
})
