$VERBOSE = nil

require 'rubygems'
require 'spork'

Spork.prefork do
       
  # from http://avdi.org/devblog/2011/04/17/rubymine-spork-rspec-cucumber/
  if ENV["RUBYMINE_HOME"]  
    $:.unshift(File.expand_path("rb/testing/patch/common", ENV["RUBYMINE_HOME"]))  
    $:.unshift(File.expand_path("rb/testing/patch/bdd", ENV["RUBYMINE_HOME"]))  
  end    
  
  # Loading more in this block will cause your tests to run faster. However,
  # if you change any configuration or code from libraries loaded here, you'll
  # need to restart spork for it take effect.
  ENV["RAILS_ENV"] ||= 'test'
  require File.expand_path("../../config/environment", __FILE__)
  require 'rspec/rails'

  # Don't need passwords in test DB to be secure, but we would like 'em to be
  # fast -- and the stretches mechanism is intended to make passwords
  # computationally expensive.
  module Devise
    module Models
      module DatabaseAuthenticatable
        protected
        def password_digest(password)
          password
        end
      end
    end
  end
  Devise.setup do |config|
    config.stretches = 0
  end

  counter = -1
  RSpec.configure do |config|
    config.mock_with :rspec
    config.use_transactional_fixtures = true

    config.after(:each) do
      counter += 1
      if counter > 9
        GC.enable
        GC.start
        GC.disable
        counter = 0
      end
    end

    config.after(:suite) do
      counter = 0
    end
  end
  ActiveRecord::Schema.verbose = false
end

Spork.each_run do
  GC.disable

  # Requires supporting ruby files with custom matchers and macros, etc,
  # in spec/support/ and its subdirectories.
  Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }
  Dir[Rails.root.join("lib/**/*.rb")].each { |f| require f }
  Dir[Rails.root.join("cdf/lib/**/*.rb")].each { |f| require f }

  Dir.glob(File.join(File.dirname(__FILE__), "../app/**/*_decorator.rb")) do |f|
    Rails.configuration.cache_classes ? require(f) : load(f)
  end  

  DatabaseCleaner.strategy = :truncation, {:except => %w[users asn_slash_codes asn_order_statuses cdf_binding_codes dc_codes po_statuses po_types poa_statuses poa_types]}
  
  
  require 'spree_core/testing_support/factories'
end
