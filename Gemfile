source 'http://rubygems.org'

gem 'rails', '3.0.9'

# Deploy with Capistrano
gem 'capistrano'

# Bundle the extra gems:
gem 'bj'
gem 'nokogiri'

gem 'haml'

# Followed by spree itself first, all spree-specific extensions second
gem 'spree', '0.60.2'

gem 'faker'
gem "factory_girl_rails"


group :production do
  gem 'mysql2', '< 0.3'
end

#
# Dev/Test gems
group :development, :test do
  gem 'sqlite3-ruby', '1.2.5', :require => 'sqlite3'
  gem 'sqlite3'
  gem 'active_reload'

end


group :cucumber, :test, :development do
  gem 'spork', '~> 0.9.0.rc'
  gem 'capybara'
  gem 'cucumber'
  gem 'cucumber-rails'
  gem 'database_cleaner'
  gem 'rspec-rails'
  gem 'rb-fsevent', :require => false if RUBY_PLATFORM =~ /darwin/i
  gem 'guard-rspec'
  gem 'guard-cucumber'
  gem 'guard-spork'
  gem 'ruby-debug-base19', ">=0.11.24"
  gem 'ruby-debug19', ">= 0.11.6"

end

gem "cdf", :path => "cdf", :require => "cdf"
gem "spree_comments", :git => 'git://github.com/spree/spree_comments.git', :branch => '0-60-x'
gem "spree_paypal_express", :git => 'git://github.com/spree/spree_paypal_express.git', :ref => "073f2f814dd8f3ad2e66ddde2c7079d8c76e4d27"
gem "acts_as_commentable"

