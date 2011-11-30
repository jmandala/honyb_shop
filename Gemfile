source 'http://rubygems.org'

gem 'rails', '3.1.1'

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

# gem 'bcrypt-ruby', '~>3.0.0'

# Deploy with Capistrano
gem 'capistrano'

# Bundle the extra gems:
#gem 'bj'
#gem 'nokogiri'

gem 'haml'

gem 'faker'
gem "factory_girl_rails"

group :production do
  gem 'mysql2'
end

gem 'ruby-debug19', :require => 'ruby-debug'

# Dev/Test gems
group :cucumber, :test, :development do
  #gem 'rails-dev-boost'
  gem 'spork', '~> 0.9.0.rc'
  gem 'capybara'
  gem 'cucumber'
  gem 'cucumber-rails'
  gem 'database_cleaner'
  gem 'rspec-rails'
  gem 'rb-fsevent', :require => false if RUBY_PLATFORM =~ /darwin/i
  #gem 'guard-rspec'
  #gem 'guard-cucumber'
  #gem 'guard-spork'
  gem 'turn', :require => false
end


# Followed by spree itself first, all spree-specific extensions second
gem 'spree'

gem "spree_comments", :git => 'git://github.com/spree/spree_comments.git'
gem "acts_as_commentable"

gem "spree_paypal_express", :git => 'git://github.com/spree/spree_paypal_express.git', :ref => "bea1aa48e0089083546bec4b19565a40e9a50a20"

gem "spree_pages", :git => 'git://github.com/BDQ/spree_pages.git'


gem "cdf", :path => "cdf", :require => "cdf"

gem 'honyb_theme', :git => 'code.mandaladesigns.com:/repos/honyb/honyb_theme.git'
#gem 'honyb_theme', :path => '../honyb_theme'