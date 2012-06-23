 Deface::Override.new(:virtual_path => %q{user_registrations/new},
                          :name => %q{replace_user_registration_new},
                          :replace => %q{#new-customer},
                          :partial => %q{overrides/user_registrations/new_customer})
