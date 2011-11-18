Deface::Override.new(:virtual_path => "shared/_order_details",
                     :name => "add_sku_to_header",
                     :insert_top => "[data-hook='order_details_line_items_headers']",
                     :text => "<th><%= t :sku %></th>",
                     :disabled => false)

Deface::Override.new(:virtual_path => "shared/_order_details",
                     :name => "add_sku_to_row",
                     :insert_top => "[data-hook='order_details_line_item_row']",
                     :text => "<td><%= item.variant.sku %></td>",
                     :disabled => false)

Deface::Override.new(:virtual_path => "shared/_order_details",
                     :name => "add_poa_to_line_item_row",
                     :insert_after => "[data-hook='order_details_line_item_row']",
                     :text => "
<% if !item.poa_line_items.empty? || !item.asn_shipment_details.empty? %>                                 
  <tr>
    <td colspan='5'>
      <div class='fulfillment_data'>                      
        <% if !item.poa_line_items.empty? %>
          <div class='poa_line_items'><%= render 'admin/fulfillment/poa_files/poa_line_items', :item => item %></div>
        <% end %>
                                  
        <% if !item.asn_shipment_details.empty? %>
          <div class='asn_shipment_details'><%= render 'admin/fulfillment/asn_files/asn_shipment_details', :item => item %></div>
        <% end %>
      </div>
    </td>
  </tr>
<% end %>
",
                     :disabled => false)


Deface::Override.new(:virtual_path => "shared/_order_details",
                     :name => "update_order_detail_colspan",
                     :set_attributes => "[colspan='3']",
                     :attributes => {:colspan => 4},
                     :disabled => false)