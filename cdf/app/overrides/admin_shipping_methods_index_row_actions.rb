Deface::Override.new(:virtual_path => "admin/shipping_methods/index",
                     :name => "shipping_method_environment_row",
                     :insert_before => "[data-hook='admin_shipping_methods_index_row_actions']",
                     :text =>  %(
    <td>
      <%= shipping_method.environment %>
      <% if shipping_method.valid_for_environment? %>
        <span class="valid">[ACTIVE]</span>
      <% else %>
        <span class="invalid">[INACTIVE]</span>
      <% end %>
    </td>    
    ),
                     :disabled => false)
