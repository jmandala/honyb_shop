
  #insert_after :admin_order_show_details, 'admin/shared/order_details_footer'
  Deface::Override.new(:virtual_path => "admin/orders/show",
                       :name => "converted_admin_order_show_details_240057451",
                       :insert_after => "[data-hook='admin_order_show_details'], #admin_order_show_details[data-hook]",
                       :partial => "admin/shared/order_details_footer",
                       :disabled => false)
