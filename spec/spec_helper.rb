require 'rubygems'
require 'spork'


Spork.prefork do

# Loading more in this block will cause your tests to run faster. However,
# if you change any configuration or code from libraries loaded here, you'll
# need to restart spork for it take effect.
  ENV["RAILS_ENV"] ||= 'test'
  require File.expand_path("../../config/environment", __FILE__)
  require 'rspec/rails'
  require 'capybara/rspec'
  require 'capybara/rails'


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
    config.treat_symbols_as_metadata_keys_with_true_values = true
    
    config.mock_with :rspec
    config.use_transactional_fixtures = false

    config.after(:each) do
      counter += 1
      if counter > 4
        GC.enable
        GC.start
        GC.disable
        counter = 0
      end
    end

    config.after(:suite) do
      counter = 0
    end

    config.before(:each) do
      DatabaseCleaner.strategy = :truncation, {:except => %w[
      asn_order_statuses 
      asn_slash_codes 
      asn_shipping_method_codes
      calculators 
      cdf_binding_codes 
      comment_types 
      configurations
      countries 
      dc_codes 
      po_box_options 
      po_statuses 
      po_types 
      poa_statuses 
      poa_types 
      preferences
      roles
      roles_users 
      shipping_methods
      states 
      tax_rate 
      users
      zones 
      zone_members ]}
    end

    config.before(:each) do
      DatabaseCleaner.start
    end

    config.after(:each) do
      DatabaseCleaner.clean
    end


  end
  ActiveRecord::Schema.verbose = false

  Delayed::Worker.delay_jobs = false    # disable delayed_job for running tests
end

Spork.each_run do
  GC.disable

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
  Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }
  Dir[Rails.root.join("lib/**/*.rb")].each { |f| require f }
  Dir[Rails.root.join("cdf/lib/**/*.rb")].each { |f| require f }
  Dir[Rails.root.join("cdf/app/**/*_decorator.rb")].each { |f| require f }

  require 'spree_core/testing_support/factories'
end
