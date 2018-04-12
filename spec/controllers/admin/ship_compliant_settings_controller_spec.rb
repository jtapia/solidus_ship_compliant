require 'spec_helper'

describe Spree::Admin::ShipCompliantSettingsController do
  stub_authorization!

   context '#edit' do
    it 'should assign a SolidusShipCompliant::Config and render the view' do
      get :edit

      expect(assigns(:config)).to be_an_instance_of(SolidusShipCompliant::Configuration)
      expect(response).to render_template('edit')
    end
  end

  context '#update' do
    let(:config) { SolidusShipCompliant::Config }

    context 'with existing value' do
      around do |example|
        default_weight = config.get_preference(:username)
        example.run
        config.set_preference(:username, default_weight)
      end

      it "updates the existing value" do
        expect(config.has_preference?(:username)).to be(true)
        post :update, params: { username: 'user_test' }
        expect(config.send("username")).to eql('user_test')
      end
    end

    context 'without existing value' do
      it "doesn't produce an error" do
        post :update, params: { 'not_real_parameter_name' => 'not_real' }
        expect(response).to redirect_to(spree.edit_admin_ship_compliant_settings_path)
      end
    end
  end
end
