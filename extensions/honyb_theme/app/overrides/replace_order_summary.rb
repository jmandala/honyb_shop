Deface::Override.new(:virtual_path => %q{checkout/_summary},
                          :name => %q{replace_order_summary'},
                          :replace => %q{[data-hook='order_summary']},
                          :partial => %q{overrides/checkout/summary},
:original => %q{<h3><%= t(:order_summary) %></h3>
<table data-hook="order_summary">
  <tbody>
    <tr data-hook="item_total">
      <td><strong><%= t(:item_total) %>:</strong></td>
      <td><strong><%= number_to_currency order.item_total %></strong></td>
    </tr>
    <tbody id="summary-order-charges" data-hook>
      <% order.adjustments.eligible.each do |adjustment| %>
      <% next if (adjustment.originator_type == "TaxRate") and (adjustment.amount == 0) %>
        <tr>
          <td><%= adjustment.label %>: </td>
          <td><%= number_to_currency adjustment.amount %></td>
        </tr>
      <% end %>
    </tbody>
    <tr data-hook="order_total">
      <td><strong><%= t(:order_total) %>:</strong></td>
      <td><strong><span id='summary-order-total'><%= number_to_currency @order.total %></span></strong></td>
    </tr>
  </tbody>
</table>
})
