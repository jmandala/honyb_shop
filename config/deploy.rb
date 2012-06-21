#require 'bundler/capistrano'
require "delayed/recipes"

set :user, 'honyb'
set :application, "honyb_shop"
set :git_server, 'code.mandaladesigns.com'
set :domain, 'www.honyb.com'
set :host, 'ruby.mandaladesigns.com'
#set :asset_env, '--trace'

# adjust if you are using RVM, remove if you are not
$:.unshift(File.expand_path('./lib', ENV['rvm_path']))
require 'rvm/capistrano'
set :rvm_ruby_string, 'ruby-1.9.2-p290@rails-3.1.1'

# file paths
set :repository, "#{git_server}:/repos/honyb/honyb_shop.git"
set :deploy_to, "/usr/local/mandala-sites/honyb/#{domain}"

set :scm, :subversion
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

role :web, host # Your HTTP server, Apache/etc
role :app, host # This may be the same as your `Web` server
role :db, host, :primary => true # This is where Rails migrations will run
#role :db,  "your slave db-server here"

set :deploy_via, :remote_cache
set :scm, 'git'
set :branch, 'master'
set :scm_verbose, true
set :use_sudo, false
set :rails_env, :production

set :keep_releases, '10'

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
namespace :deploy do
  desc 'cause Passenger to initiate a restart'
  task :restart do
    run "touch #{current_path}/tmp/restart.txt"
  end

  desc 'reload database with seed data'
  task :seed do
    run "cd #{current_path}; rake db:seed RAILS_ENV=#{rails_env}"
  end

  desc 'load the cdf seeds'
  task :cdf_seed do
    run "cd #{current_path}; rake cdf:db:seed RAILS_ENV=#{rails_env}"
  end
end

after 'deploy:update_code', :bundle_install
after 'deploy:restart', :run_post_commands
after "deploy:stop",    "delayed_job:stop"
after "deploy:start",   "delayed_job:start"
after "deploy:restart", "delayed_job:restart"

desc 'install the necessary prerequisites'
task :bundle_install, :roles => :app do
  run "cd #{release_path} && rvm gem install sqlite3 -- --with-sqlite3-dir=/opt/local/sqlite-3.7.0.9"
  run "cd #{release_path} && bundle install --without development test"
end

desc 'post install and restart commands'
task :run_post_commands, :roles => :app do
  run "cd #{release_path} && whenever --update-crontab honyb_shop"
end

desc "tail production log files"
task :tail, :roles => :app do
  run "tail -f #{shared_path}/log/production.log" do |channel, stream, data|
    puts # for an extra line break before the host name
    puts "#{channel[:host]}: #{data}"
    break if stream == :err
  end
end

namespace :assets do
  desc "create symlinks from shared resources to the release path"
  task :symlink, :roles => :app do

    symlink_to_shared '/public/spree/products', '/uploaded-files/spree/products'
    symlink_to_shared '/cdf/data_lib'
    symlink_to_shared '/cdf/config/config.yml'
  end
end

after "deploy:update_code", "assets:symlink"
after "deploy", "deploy:cleanup"

load 'deploy/assets'

# @returns true if path is a directory -- has not file extension
def path_is_dir(path)
  File.extname(path) == ''
end

# Creates a symlink from the <tt>from</tt> path within the release to the <tt>to</tt> path 
# in the shared path.
# 
# If <tt>to</tt> is nil, use the <tt>from</tt> path value
def symlink_to_shared(from, to = nil)
  orig_path = release_path + from

  if to
    dest_path = shared_path + to
  else 
    dest_path = shared_path + from    
  end

  run "mkdir -p #{orig_path}" if path_is_dir orig_path
  run "mkdir -p #{dest_path}" if path_is_dir dest_path  

  # if the original path exists, 
  # and the path is a directory
  # rsync all the existing files to the destination first
  # then delete it
  run "if [ -d '#{orig_path}' ]; then rsync -avz #{orig_path}/ #{dest_path}; fi" if path_is_dir orig_path
  
  run "rm -rf #{orig_path} && ln -s #{dest_path} #{orig_path}"
  
end
