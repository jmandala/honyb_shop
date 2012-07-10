# STAGING
set :rails_env, 'staging'

server 'stage.honyb.com', :app, :web, :primary => true

set :branch, 'origin/wip/merge-automation-master'

set :application, 'stage.honyb.com'
role :db, "stage.honyb.com", :primary => true

set :deploy_to, "/usr/local/mandala-sites/honyb/#{application}"

default_environment["RAILS_ENV"] = 'staging'