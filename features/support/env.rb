$VERBOSE = nil

require 'rubygems'
require 'spork'
#require 'spork/ext/ruby-debug'


Spork.prefork do
  ENV["RAILS_ENV"] ||= "cucumber"
  require File.expand_path(File.dirname(__FILE__) + '/../../config/environment')

  require 'cucumber'
  require 'cucumber/rails'
  require 'cucumber/formatter/unicode' # Comment out this line if you don't want Cucumber Unicode support
  require 'rspec/rails'
  require 'cucumber/rails/rspec'

  Capybara.default_selector = :css
end

Spork.each_run do
  @configuration ||= AppConfiguration.find_or_create_by_name("Default configuration")
  
  
  ActionController::Base.allow_rescue = false
  Cucumber::Rails::World.use_transactional_fixtures = true

  begin
    DatabaseCleaner.strategy = :truncation, {:except => %w[users asn_slash_codes asn_order_statuses cdf_binding_codes dc_codes po_statuses po_types poa_statuses poa_types]}
  rescue NameError
    raise "You need to add database_cleaner to your Gemfile (in the :test group) if you wish to use it."
  end

  Dir.glob(File.join(File.dirname(__FILE__), "../app/**/*_decorator.rb")) do |f|
    Rails.configuration.cache_classes ? require(f) : load(f)
  end

  require 'spree_core/testing_support/factories'

end