Deface::Override.new(:virtual_path => "admin/configurations/index",
                     :name => "converted_admin_configurations_menu_420615273",
                     :insert_bottom => "[data-hook='admin_configurations_menu'], #admin_configurations_menu[data-hook]",
                     :text => "
    <tr>
        <td><%= link_to t(:fulfillment), admin_fulfillment_settings_path %></td>
        <td><%= t(:fulfillment_settings_description) %></td>
      </tr>
    ",
                     :disabled => false)
