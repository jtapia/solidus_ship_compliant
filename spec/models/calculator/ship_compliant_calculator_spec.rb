require 'spec_helper'

describe Spree::Calculator::ShipCompliantCalculator do
  let(:calculator) { Spree::Calculator::ShipCompliantCalculator.new }

  describe '.description' do
    it 'should not be nil' do
      expect(Spree::Calculator::ShipCompliantCalculator.description).to eq Spree.t(:ship_compliant_tax)
    end
  end

  describe '#compute_order' do
    it 'should raise an error' do
      expect {
        calculator.compute_order(nil)
      }.to raise_error(RuntimeError)
    end
  end
end
