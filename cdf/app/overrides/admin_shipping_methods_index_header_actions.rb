Deface::Override.new(:virtual_path => "admin/shipping_methods/index",
                     :name => "shipping_method_environment_header",
                     :insert_before => "[data-hook='admin_shipping_methods_index_header_actions']",
                     :text => "<th><%= t('environment') %></th>",
                     :disabled => false)
