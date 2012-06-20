Rails.application.routes.draw do
  
  match '/admin/reports/sales_detail' => 'admin/reports#sales_detail',  :via  => [:get, :post],
                                                              :as   => 'sales_detail_admin_reports'
  
end
