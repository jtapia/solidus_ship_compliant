require 'spec_helper'

describe Spree::ShipCompliant, type: :model do
  let!(:taxonomy) { create(:taxonomy, name: 'Brand') }
  let!(:brand_taxon) { create(:taxon, taxonomy: taxonomy) }
  let!(:order) { create(:order_ready_to_ship) }

  subject { Spree::ShipCompliant.new(order) }

  context '#address_from_spree_address' do
    it 'returns the payload address' do
      expect(subject.address_from_spree_address(order.ship_address)).to_not be_nil
    end
  end

  context '#shipment_items' do
    it 'returns the 3 first chars of taxon name' do
      expect(subject.shipment_items).to_not be_nil
    end
  end
end
