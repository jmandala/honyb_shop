

Deface::Override.new(:virtual_path => "layouts/admin",
                     :name => "converted_admin_inside_head_388546301",
                     :insert_after => "[data-hook='admin_inside_head'], #admin_inside_head[data-hook]",
                     :text => "<%= stylesheet_link_tag 'admin/cdf' %>",
                     :disabled => false)
