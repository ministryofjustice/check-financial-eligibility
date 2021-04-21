require 'rails_helper'

module Decorators
  module V3
    RSpec.describe DeductionsDecorator do
      describe '#as_json' do
        subject { described_class.new(record).as_json }

        let(:record) { create :disposable_income_summary, dependant_allowance: 1283.66 }
        it 'returns expected hash' do
          expect(Calculators::DisregardedStateBenefitsCalculator).to receive(:call).with(record).and_return(587.00)
          expected_hash = {
            dependants_allowance: 1283.66,
            disregarded_state_benefits: 587.00
          }
          expect(subject).to eq expected_hash
        end
      end
    end
  end
end
