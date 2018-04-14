require 'spec_helper'

describe Spree::Variant, type: :model do
  let!(:taxonomy) { create(:taxonomy, name: 'Brand') }
  let!(:brand_taxon) { create(:taxon, taxonomy: taxonomy) }
  let!(:bottle_size_option_type) { create(:option_type, name: 'Bottle Size', presentation: 'Bottle Size') }
  let!(:bottle_size_option_value) { create(:option_value, option_type: bottle_size_option_type) }
  let!(:default_case) { create(:property, name: 'default_case') }
  let!(:default_wholesale_case_price) { create(:property, name: 'default_wholesale_case_price') }
  let!(:percent_alcohol) { create(:property, name: 'percent_alcohol') }
  let!(:varietal) { create(:property, name: 'varietal') }
  let!(:vintage) { create(:property, name: 'vintage') }
  let!(:volume_amount) { create(:property, name: 'volume_amount') }
  let!(:volume_unit) { create(:property, name: 'volume_unit') }

  let!(:product) { create(:product, taxons: [brand_taxon]) }

  let!(:bottle_size_product_property) { create(:product_option_type, product: product, option_type: bottle_size_option_type) }
  let!(:default_case_product_property) { create(:product_property, product: product, property: default_case, value: '1') }
  let!(:default_wholesale_case_price_product_property) { create(:product_property, product: product, property: default_wholesale_case_price, value: '670') }
  let!(:percent_alcohol_product_property) { create(:product_property, product: product, property: percent_alcohol, value: '5%') }
  let!(:varietal_product_property) { create(:product_property, product: product, property: varietal, value: 'Cabernet Sauvignon') }
  let!(:vintage_product_property) { create(:product_property, product: product, property: vintage, value: '2003') }
  let!(:volume_amount_product_property) { create(:product_property, product: product, property: volume_amount, value: '750') }
  let!(:volume_unit_product_property) { create(:product_property, product: product, property: volume_unit, value: 'milliliter') }

  let!(:variant) { create(:variant, product: product) }

  context 'validations' do
    it 'should validate bottle_size is present' do
      expect(variant.brand_key).to_not be_nil
    end

    it 'should validate bottle_size is present' do
      expect(variant.product_key).to_not be_nil
    end

    it 'should validate bottle_size is present' do
      expect(variant.bottle_size).to_not be_nil
    end

    it 'should validate default_case is present' do
      expect(variant.default_case).to_not be_nil
    end

    it 'should validate default_wholesale_case_price is present' do
      expect(variant.default_wholesale_case_price).to_not be_nil
    end

    it 'should validate percent_alcohol is present' do
      expect(variant.percent_alcohol).to_not be_nil
    end

    it 'should validate varietal is present' do
      expect(variant.varietal).to_not be_nil
    end

    it 'should validate vintage is present' do
      expect(variant.vintage).to_not be_nil
    end

    it 'should validate volume_amount is present' do
      expect(variant.volume_amount).to_not be_nil
    end

    it 'should validate volume_unit is present' do
      expect(variant.volume_unit).to_not be_nil
    end
  end
end
