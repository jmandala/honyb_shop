require 'site_hooks'

module SpreeSite
  class Engine < Rails::Engine
    def self.activate

      # include the ext
      Dir.glob(File.join(File.dirname(__FILE__), "ext/**/*.rb")) do |c|
        Rails.env.production? ? require(c) : load(c)
      end

      Spree::Config.set(:checkout_zone => 'ALL US')
      
    end
    

    config.to_prepare &method(:activate).to_proc
  end
end