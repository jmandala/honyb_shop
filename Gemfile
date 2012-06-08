source 'http://rubygems.org'

gem 'rails', '3.1.4'

gem 'sqlite3'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'therubyracer'
  gem 'sass-rails',   '~> 3.1.4'
  gem 'coffee-rails', '~> 3.1.1'
  gem 'uglifier', '>= 1.0.3'
end

gem 'jquery-rails'
gem 'capistrano'
gem 'haml'
gem 'faker'
gem "factory_girl_rails"

group :production do
  gem 'mysql2'
end

# Dev/Test gems
group :test, :development do
  gem 'launchy'
  gem 'spork', '~> 0.9.0.rc'
  gem 'capybara'
  gem 'database_cleaner'
  gem 'rspec-rails'
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

gem "cdf", :path => "cdf", :require => "cdf"

gem 'routing-filter'

gem 'rack-p3p', :git => 'git://github.com/jmandala/rack-p3p.git'
gem 'rack-jsonp-middleware'

#gem 'ie_iframe_cookies'

gem 'honyb_theme', :git => 'code.mandaladesigns.com:/repos/honyb/honyb_theme.git',:ref => "e66503ec9d82384d7458c35ffde365a70c3a94f6"
#gem 'honyb_theme', :path => '../honyb_theme'