Deface::Override.new(:virtual_path => "layouts/admin",
                     :name => "admin_order_tabs",
                     :insert_bottom => "[data-hook='admin_order_tabs'], #admin_tabs[data-hook]",
                     :text =>   %(<li<%== ' class="active"' if current == "Fulfillment" %>>
       <%= link_to t(:fulfillment), fulfillment_admin_order_path(@order) %> ???
    </li>
    ),
                     :disabled => false)
