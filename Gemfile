source 'http://rubygems.org'

gem 'rails', '3.0.9'

gem 'sqlite3'


# Deploy with Capistrano
gem 'capistrano'

# Bundle the extra gems:
gem 'bj'
gem 'nokogiri'
gem 'sqlite3-ruby', :require => 'sqlite3'

gem 'haml'

# Followed by spree itself first, all spree-specific extensions second
gem 'spree', '0.60.1'

#
# Dev/Test gems
group :development, :test do
  gem 'sqlite3'
  gem 'active_reload'

end

group :cucumber, :test, :development do
  gem 'spork', '~> 0.9.0.rc'
  gem 'faker'
  gem "factory_girl_rails"
  gem 'capybara'
  gem 'cucumber'
  gem 'cucumber-rails'
  gem 'database_cleaner'
  gem 'rspec-rails'
  gem 'webrat'
  gem 'rb-fsevent', :require => false if RUBY_PLATFORM =~ /darwin/i
  #gem 'rb-inotify', :require => false if RUBY_PLATFORM =~ /linux/i
  gem 'guard-rspec'
  gem 'guard-cucumber'
  gem 'guard-spork'
end

gem "cdf", :path => "cdf", :require => "cdf"
