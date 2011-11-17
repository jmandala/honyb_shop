Deface::Override.new(:virtual_path => "layouts/admin",
                     :name => "fulfillment_admin_tabs",
                     :insert_bottom => "[data-hook='admin_tabs'], #admin_tabs[data-hook]",
                     :text => "<%=  tab :fulfillment_dashboard, :po_files, :poa_files, :asn_files, :cdf_invoice_files, :system_check, :dashboard %>",
                     :disabled => false)
