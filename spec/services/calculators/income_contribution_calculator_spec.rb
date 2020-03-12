require 'rails_helper'

module Calculators
  RSpec.describe IncomeContributionCalculator do
    describe '.call' do
      subject { described_class.call(income) }

      context 'income below band a' do
        let(:income) { 312.0 }
        it 'returns zero' do
          expect(subject).to be_zero
        end
      end

      context 'income in band a' do
        let(:income) { 340.0 }
        # (340 - 311) * 35% = 10.15
        it 'returns 35% of income less £311' do
          expect(subject).to eq 10.15
        end
      end

      context 'income in band b' do
        let(:income) { 611.43 }
        # 53.90 + ((611.43 - 465) * 45%) = 119.79
        it 'returns £53.90 + 45% of income less £455.99' do
          expect(subject).to eq 119.79
        end
      end

      context 'income in band c' do
        let(:income) { 4_326.77 }
        # 121.85 + ((4_326.77 - 616) * 70%) = 2,719.39
        it 'returns £121.85 + 70% of income less 616.99' do
          expect(subject).to eq 2_719.39
        end
      end
    end
  end
end
