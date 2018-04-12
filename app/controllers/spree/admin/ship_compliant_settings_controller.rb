module Spree
  module Admin
    class ShipCompliantSettingsController < Spree::Admin::BaseController
      before_action :load_config

      def edit
        @preferences_ship_compliant = [:username, :password, :partner_key, :service_url]
      end

      def update
        params.each do |name, value|
          next unless @config.has_preference? name
          @config[name] = value
        end

        flash[:success] = Spree.t(:ship_compliant_settings_updated)
        redirect_to edit_admin_ship_compliant_settings_path
      end

      private

      def load_config
        @config ||= SolidusShipCompliant::Config
      end
    end
  end
end