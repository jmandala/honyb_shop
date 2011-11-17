

  #insert_before :admin_order_show_addresses, 'admin/shared/order_details_before_addresses'
  Deface::Override.new(:virtual_path => "admin/orders/show",
                       :name => "converted_admin_order_show_addresses_756039867",
                       :insert_before => "[data-hook='admin_order_show_addresses'], #admin_order_show_addresses[data-hook]",
                       :partial => "admin/shared/order_details_before_addresses",
                       :disabled => false)
