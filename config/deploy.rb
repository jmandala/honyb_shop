set :user, 'honyb'
set :application, "honyb_shop"
set :git_server, 'code.mandaladesigns.com'
set :domain, 'www.honyb.com'
set :host, 'ruby.mandaladesigns.com'

# adjust if you are using RVM, remove if you are not
$:.unshift(File.expand_path('./lib', ENV['rvm_path']))
require 'rvm/capistrano'
set :rvm_ruby_string, 'ruby-1.9.2-p290@rails-3.1.1'

# file paths
set :repository, "#{user}@#{git_server}:/repos/honyb/honyb_shop.git"
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

desc 'install the necessary prerequisites'
task :bundle_install, :roles => :app do
  run "cd #{current_path} && gem install sqlite3 -- --with-sqlite3-dir=/opt/local/sqlite-3.7.0.9"
  run "cd #{current_path} && bundle install"
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

  desc "create the shared directories"
  task :create_dirs, :roles => :app do
    %w(uploaded-files).each do |name|
      run "mkdir -p #{shared_path}/#{name}"
    end
  end

  desc "create symlinks from shared resources to the release path"
  task :symlink, :roles => :app do
    assets.create_dirs

    release_image_dir = "#{current_path}/public/spree/products/"
    shared_image_dir = "#{shared_path}/uploaded-files/spree/products/"

    run "rm -rf #{release_image_dir}"

    [release_image_dir, shared_image_dir].each { |path| run "mkdir -p #{path}" }

    run "ln -nfs #{shared_image_dir} #{release_image_dir}"
  end

end

after "deploy:update_code", "assets:symlink"

load 'deploy/assets'
