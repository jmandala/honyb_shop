module Cdf
  class Config < Spree::Config
    RUN_MODE = [:live, :test, :mock]

    class << self

      def instance
        return nil unless ActiveRecord::Base.connection.tables.include?('configurations')
        CdfConfiguration.find_or_create_by_name("CDF configuration")
      end

      # initializes the :cdf_run_mode preference according to the rails environment
      # production = :live
      # development = :mock
      # other = :test
      def init_cdf_run_mode
        if Rails.env.production?
          self.set(:cdf_run_mode => :live)
        elsif Rails.env.development?
          self.set(:cdf_run_mode => :mock)
        else
          self.set(:cdf_run_mode => :test)
        end
      end
    end

    self.init_cdf_run_mode

  end
end