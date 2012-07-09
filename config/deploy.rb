# Borrowed heavily from: http://ariejan.net/2011/09/14/lighting-fast-zero-downtime-deployments-with-git-capistrano-nginx-and-unicorn
require 'bundler/capistrano'
require "delayed/recipes"


# Multi-stage deploy's explained here: https://github.com/capistrano/capistrano/wiki/2.x-Multistage-Extension
set :stages, %w(staging production)
set :default_stage, 'staging'
require 'capistrano/ext/multistage'


set :scm, :git
set :git_server, 'code.mandaladesigns.com'
set :repository, "#{git_server}:/repos/honyb/honyb_shop.git"
set :migrate_target, :current
set :ssh_options, {:forward_agent => true}


set :normalize_timestamps, false

set :user, 'honyb'
set :group, "honyb"
set :use_sudo, false


set(:latest_release) { fetch(:current_path) }
set(:release_path) { fetch(:current_path) }
set(:current_release) { fetch(:current_path) }

set(:current_revision) { capture("cd #{current_path}; git rev-parse --short HEAD").strip }
set(:latest_revision) { capture("cd #{current_path}; git rev-parse --short HEAD").strip }
set(:previous_revision) { capture("cd #{current_path}; git rev-parse --short HEAD@{1}").strip }


# Use our ruby-1.9.2-p290@my_site gemset
default_environment["PATH"] = "/usr/local/rvm/gems/ruby-1.9.2-p290/bin:/usr/local/rvm/gems/ruby-1.9.2-p290@global/bin:/usr/local/rvm/rubies/ruby-1.9.2-p290/bin:/usr/local/rvm/bin:/home/honyb/bin:/usr/kerberos/bin:/usr/local/bin:/bin:/usr/bin"
default_environment["GEM_HOME"] = "/usr/local/rvm/gems/ruby-1.9.2-p290"
default_environment["GEM_PATH"] = "/usr/local/rvm/gems/ruby-1.9.2-p290:/usr/local/rvm/gems/ruby-1.9.2-p290@global"
default_environment["RUBY_VERSION"] = "ruby-1.9.2-p290"

default_run_options[:shell] = 'bash'

set :scm_verbose, true

namespace :deploy do
  desc "Deploy your application"
  task :default do
    update
    restart
  end

  desc "Setup your git-based deployment app"
  task :setup, :except => {:no_release => true} do
    dirs = [deploy_to, shared_path]
    dirs += shared_children.map { |d| File.join(shared_path, d) }
    run "#{try_sudo} mkdir -p #{dirs.join(' ')} && #{try_sudo} chmod g+w #{dirs.join(' ')}"
    run "git clone #{repository} #{current_path}"
    update
  end

  task :cold do
    update
    migrate
  end

  task :update do
    transaction do
      update_code
    end
  end

  desc "Update the deployed code."
  task :update_code, :except => {:no_release => true} do
    run "mkdir -p #{current_path} && cd #{current_path} && git fetch origin; git reset --hard #{branch}"
    finalize_update
  end

  desc "Update the database (overwritten to avoid symlink)"
  task :migrations do
    transaction do
      update_code
    end
    migrate
    restart
  end

  namespace :assets do
    task :precompile, :roles => :web, :except => {:no_release => true} do
      from = source.next_revision(current_revision)
      if capture("cd #{latest_release} && #{source.local.log(from)} vendor/assets/ app/assets/ | wc -l").to_i > 0
        run %Q{cd #{latest_release} && #{rake} RAILS_ENV=#{rails_env} #{asset_env} assets:precompile}
      else
        logger.info "Skipping asset pre-compilation because there were no asset changes"
      end
    end
  end

  task :finalize_update, :except => {:no_release => true} do
    run "chmod -R g+w #{latest_release}" if fetch(:group_writable, true)

    # mkdir -p is making sure that the directories are there for some SCM's that don't
    # save empty folders
    run <<-CMD
      rm -rf #{latest_release}/log #{latest_release}/public/system #{latest_release}/tmp/pids &&
      mkdir -p #{latest_release}/public &&
      mkdir -p #{latest_release}/tmp &&
      ln -s #{shared_path}/log #{latest_release}/log &&
      ln -s #{shared_path}/system #{latest_release}/public/system &&
      ln -s #{shared_path}/pids #{latest_release}/tmp/pids &&
      ln -sf #{shared_path}/database.yml #{latest_release}/config/database.yml
    CMD

    if fetch(:normalize_asset_timestamps, true)
      stamp = Time.now.utc.strftime("%Y%m%d%H%M.%S")
      asset_paths = fetch(:public_children, %w(images stylesheets javascripts)).map { |p| "#{latest_release}/public/#{p}" }.join(" ")
      run "find #{asset_paths} -exec touch -t #{stamp} {} ';'; true", :env => {"TZ" => "UTC"}
    end
  end

  desc "Zero-downtime restart of Unicorn"
  task :restart, :except => {:no_release => true} do
    run "kill -s USR2 `cat /tmp/unicorn.honyb.pid`"
  end

  desc "Start unicorn"
  task :start, :except => {:no_release => true} do
    run "cd #{current_path} && bundle exec unicorn_rails -c config/unicorn.rb -D"
  end

  desc "Stop unicorn"
  task :stop, :except => {:no_release => true} do
    run "kill -s QUIT `cat /tmp/unicorn.honyb.pid`"
  end

  namespace :rollback do
    desc "Moves the repo back to the previous version of HEAD"
    task :repo, :except => {:no_release => true} do
      set :branch, "HEAD@{1}"
      deploy.default
    end

    desc "Rewrite reflog so HEAD@{1} will continue to point to at the next previous release."
    task :cleanup, :except => {:no_release => true} do
      run "cd #{current_path} && git reflog delete --rewrite HEAD@{1} && git reflog delete --rewrite HEAD@{1}"
    end

    desc "Rolls back to the previously deployed version."
    task :default do
      rollback.repo
      rollback.cleanup
    end
  end


  desc 'reload database with seed data'
  task :seed do
    run <<-CMD
      cd #{current_path} &&
      bundle exec rake db:seed cdf:db:seed AUTO_ACCEPT=1 RAILS_ENV=#{rails_env}
    CMD
  end

  desc 'load the cdf seeds'
  task :cdf_seed do
    run <<-CMD 
      cd #{current_path} && 
      bundle exec rake cdf:db:seed 
    CMD
  end

end

def run_rake(cmd)
  run "cd #{current_path}; #{rake} #{cmd}"
end

#after 'deploy:update_code', "deploy:migrate"
#after 'deploy:start', :run_post_commands

#after "deploy:stop",    "delayed_job:stop"
#after "deploy:start",   "delayed_job:start"
#after "deploy:restart", "delayed_job:restart"

desc 'post install and restart commands'
task :run_post_commands, :roles => :app do
  run "cd #{release_path} && whenever --update-crontab honyb_shop"
end

#desc "tail production log files"
#task :tail, :roles => :app do
#  run "tail -f #{shared_path}/log/production.log" do |channel, stream, data|
#    puts # for an extra line break before the host name
#    puts "#{channel[:host]}: #{data}"
#    break if stream == :err
#  end
#end

namespace :assets do
  desc "create symlinks from shared resources to the release path"
  task :symlink, :roles => :app do

    symlink_to_shared '/public/spree/products', '/uploaded-files/spree/products'
    symlink_to_shared '/public/spree/honyb', '/uploaded-files/spree/honyb'
    symlink_to_shared '/cdf/data_lib'
    symlink_to_shared '/cdf/config/config.yml'
  end
end

after "deploy:update_code", "assets:symlink"
after "deploy", "deploy:cleanup"

load 'deploy/assets'

task :uname do
  run "uname -a"
end



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
