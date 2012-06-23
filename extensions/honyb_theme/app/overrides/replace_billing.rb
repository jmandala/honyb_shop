Deface::Override.new(:virtual_path => %q{checkout/_address},
                          :name => %q{replace_billing},
                          :replace => %q{#billing[data-hook]},
                          :partial => %q{checkout/addresses})
