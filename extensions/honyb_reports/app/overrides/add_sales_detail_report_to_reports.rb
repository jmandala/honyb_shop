Deface::Override.new(:virtual_path => %q{admin/reports/index},
                     :name => %q{add_sales_detail_report_to_reports},
                     :insert_before => %q{[data-hook='reports_row']},
                     :text => %q{<tr><td>Sales Detail</td><td>Includes orders, line items, customer, and export options</td></tr>},
                     :original => %q{<h1><%= t(:listing_reports) %></h1>

<table class="index">
  <thead>
    <tr data-hook="reports_header">
      <th><%= t(:name) %></th>
      <th><%= t(:description) %></th>
    </tr>
  </thead>
  <tbody>
    <% @reports.each do |key, value| %>
    <tr data-hook="reports_row">
      <td><%= link_to value[:name], send("#{key}_admin_reports_url".to_sym) %></td>
      <td><%= value[:description] %></td>
    </tr>
    <% end %>
  </tbody>
</table>

})
