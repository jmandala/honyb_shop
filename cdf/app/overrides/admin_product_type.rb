  #insert_after :admin_product_form_meta
  Deface::Override.new(:virtual_path => "admin/products/_form",
                       :name => "admin_products_add_type",
                       :insert_after => "[data-hook='admin_product_form_meta'], #admin_product_form_meta[data-hook]",
                       :partial => "admin/products/product_type",
                       :disabled => false)