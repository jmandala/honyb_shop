
  #insert_after :admin_order_show_buttons, 'admin/shared/order_details_extra_buttons'
  Deface::Override.new(:virtual_path => "admin/orders/show",
                       :name => "converted_admin_order_show_buttons_435560197",
                       :insert_after => "[data-hook='admin_order_show_buttons'], #admin_order_show_buttons[data-hook]",
                       :partial => "admin/shared/order_details_extra_buttons",
                       :disabled => false)