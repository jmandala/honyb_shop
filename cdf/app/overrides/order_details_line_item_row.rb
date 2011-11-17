  #replace :order_details_line_item_row, 'admin/shared/order_details_line_item_row'  
  Deface::Override.new(:virtual_path => "shared/_order_details",
                       :name => "converted_order_details_line_item_row_850554700",
                       :replace => "[data-hook='order_details_line_item_row'], #order_details_line_item_row[data-hook]",
                       :partial => "admin/shared/order_details_line_item_row",
                       :disabled => false)

