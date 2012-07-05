source 'http://rubygems.org'

gem 'rails', '3.1.4'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'therubyracer'
  gem 'sass-rails',   '3.1.4'
  gem 'coffee-rails', '~> 3.1.1'
  gem 'uglifier', '>= 1.0.3'
end

gem 'jquery-rails'
gem 'haml'
gem 'faker'
gem "factory_girl_rails"

group :production do
  gem 'mysql2'
end

gem "unicorn"

group :development do
  gem "capistrano"
end

# Dev/Test gems
group :test, :development do
  gem 'sqlite3'
  gem 'launchy'
  gem 'spork', '~> 0.9.0.rc'
  gem 'capybara'
  gem 'database_cleaner'
  gem 'rspec-rails', "~> 2.0"
  gem 'rb-fsevent', :require => false if RUBY_PLATFORM =~ /darwin/i
  gem 'guard-rspec'
  gem 'minitest-reporters', '>= 0.5.0'
  gem 'guard-spork'
  gem 'turn', :require => false
end

gem 'spree', '0.70.5'

gem "spree_comments", :git => 'git://github.com/spree/spree_comments.git', :ref => "a33693ffaeb60fc8bcde6c805c9659ff4b7e2bd6"
gem "acts_as_commentable"

gem "spree_paypal_express", :git => 'git://github.com/spree/spree_paypal_express.git', :ref => "bea1aa48e0089083546bec4b19565a40e9a50a20"

gem "spree_pages", :git => 'git://github.com/BDQ/spree_pages.git'

gem 'routing-filter'

gem 'rack-p3p', :git => 'git://github.com/jmandala/rack-p3p.git'
gem 'rack-jsonp-middleware'

gem 'delayed_job_active_record'
gem 'daemons'
gem 'whenever', :require => false

gem 'ruport'
gem 'ruport-util'
gem 'acts_as_reportable'

# HONYB EXTENSIONS
gem "cdf", :path => "cdf" # todo: move to the 'extensions' dir
gem 'honyb_affiliate', :path => 'extensions/honyb_affiliate'
gem 'honyb_reports', :path => 'extensions/honyb_reports'
gem 'honyb_theme', :path => 'extensions/honyb_theme'
