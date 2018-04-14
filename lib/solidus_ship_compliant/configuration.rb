module SolidusShipCompliant
  class Configuration < Spree::Preferences::Configuration
    preference :username, :string, default: ''
    preference :password, :string, default: ''
    preference :partner_key, :string, default: ''
  end
end
