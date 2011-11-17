Deface::Override.new(:virtual_path => "admin/shared/_configuration_menu",
                     :name => "converted_admin_configurations_sidebar_menu_712529366",
                     :insert_bottom => "[data-hook='admin_configurations_sidebar_menu'], #admin_configurations_sidebar_menu[data-hook]",
                     :text => %(
    <%= configurations_sidebar_menu_item t(:fulfillment), admin_fulfillment_settings_path %>
    ),
                     :disabled => false)

Deface::Override.new(:virtual_path => "admin/shared/_configuration_menu",
                     :name => "replaced_general_settings_menu_item",
                     :replace => "code[erb-loud]:contains('general_settings')",
                     :original => "<%= configurations_sidebar_menu_item t(:general_settings), admin_general_settings_path %>",
                     :text => %(
<% css_class = controller.class == Admin::GeneralSettingsController ? 'active' : '' %> 
<%= content_tag(:li, :class => css_class) { link_to(t(:general_settings), admin_general_settings_path) } %>
    ))

Deface::Override.new(:virtual_path => "admin/shared/_configuration_menu",
                     :name => "replaced_inventory_settings_menu_item",
                     :replace => "code[erb-loud]:contains('inventory_settings')",
                     :original => "<%= configurations_sidebar_menu_item t(:inventory_settings), admin_inventory_settings_path %>",
                     :text => %(
<% css_class = controller.class == Admin::InventorySettingsController ? 'active' : '' %> 
<%= content_tag(:li, :class => css_class) { link_to(t(:inventory_settings), admin_inventory_settings_path) } %>
    ))