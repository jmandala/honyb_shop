Deface::Override.new(:virtual_path => %q{products/show},
                     :name => %q{remove_products_show_taxons},
                     :remove => %q{code[erb-loud]:contains("render 'taxons'")})

