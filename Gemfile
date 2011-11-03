source 'http://rubygems.org'

gem 'rails', '3.0.9'

# Deploy with Capistrano
gem 'capistrano'

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
  gem 'mysql2'
end

#
# Dev/Test gems
group :development, :test do
  gem 'sqlite3-ruby', :require => 'sqlite3'
  gem 'sqlite3', '1.2.5'
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
gem "acts_as_commentable"
