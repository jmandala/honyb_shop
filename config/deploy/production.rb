# PRODUCTION
set :rails_env, 'production'


role :web, "www1.honyb.com", "www2.honyb.com"
role :app, "www1.honyb.com", "www2.honyb.com"
role :db, "www1.honyb.com", :primary => true # This is where Rails migrations will run

set :branch, 'origin/master'


set :application, "www.honyb.com"
set :deploy_to, "/usr/local/mandala-sites/honyb/#{application}"


default_environment["RAILS_ENV"] = 'production'
