require 'spec_helper'

describe Spree::Taxon, type: :model do
  let!(:taxon) { create(:taxon, name: 'Brand') }

  context '#brand_key' do
    it 'returns the 3 first chars of taxon name' do
      expect(taxon.brand_key).to eql('BRA')
    end

    it 'returns the first char of taxon name splitted' do
      taxon.name = 'Test Taxon'
      expect(taxon.brand_key).to eql('TT')
    end
  end
end