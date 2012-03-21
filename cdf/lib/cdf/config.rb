module Cdf
  class Config < Spree::Config
    RUN_MODE = [:live, :test, :mock] unless Config.const_defined? :RUN_MODE

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
        else
          self.set(:cdf_run_mode => :mock)
        end
      end
      
      # Initializes from config.yml in order to set
      # default values for all required properties
      def init_from_config(flag=nil)
        yaml = YAML::load_file(File.join(Rails.root, 'cdf/config/config.yml'))
        yaml.keys.each { |key| self.set(key.to_sym => yaml[key]) unless flag == :overwrite && (self[key.to_sym] || self[key.to_sym].empty?) }
      end
    end

    self.init_from_config
    self.init_cdf_run_mode

  end
end