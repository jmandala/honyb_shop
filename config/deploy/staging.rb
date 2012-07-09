# STAGING

server 'stage.honyb.com', :app, :web, :primary => true

set :branch, 'origin/wip/capistrano-enhancement'


set :application, 'stage.honyb.com'
set :deploy_to, "/usr/local/mandala-sites/honyb/#{application}"

default_environment["RAILS_ENV"] = 'staging'