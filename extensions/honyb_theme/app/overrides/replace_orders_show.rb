Deface::Override.new(:virtual_path => %q{orders/show},
                          :name => %q{replace_orders_show},
                          :replace => %q{#order[data-hook]},
                          :template => %q{overrides/orders/show})
