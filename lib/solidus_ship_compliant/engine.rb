module SolidusShipCompliant
  class Engine < Rails::Engine
    require 'spree/core'
    isolate_namespace Spree
    engine_name 'solidus_ship_compliant'

    config.autoload_paths += %W(#{config.root}/lib)

    # use rspec for tests
    config.generators do |g|
      g.test_framework :rspec
    end

    initializer 'solidus_ship_compliant.environment', before: :load_config_initializers do |app|
      SolidusShipCompliant::Config = SolidusShipCompliant::Configuration.new
    end

    initializer 'solidus_ship_compliant.register.calculators', after: 'spree.register.calculators' do |app|
      SolidusShipCompliant::Config = SolidusShipCompliant::Configuration.new
      app.config.spree.calculators.tax_rates << Spree::Calculator::ShipCompliantCalculator
    end

    def self.activate
      Dir.glob(File.join(File.dirname(__FILE__), '../../app/**/*_decorator*.rb')) do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end
    end

    config.to_prepare(&method(:activate).to_proc)
  end
end
