Deface::Override.new(:virtual_path => %q{products/show},
                     :name => %q{add_taxonomies_to_product_show},
                     :insert_after => %q{[data-hook='product_show']},
                     :sequence => {:after => 'add_recently_viewed_products_to_products_show'},
                     :text => %q{},
                    :disable => true)
