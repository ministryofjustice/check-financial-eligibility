require 'rails_helper'

module Decorators
  RSpec.describe DisposableIncomeSummaryDecorator do
    describe '#as_json' do
      subject { described_class.new(disposable_income_summary).as_json }

      context 'disposable income summary is nil' do
        let(:disposable_income_summary) { nil }
        it 'returns nil' do
          expect(subject).to be_nil
        end
      end

      context 'disposable income summary exists' do
        let(:disposable_income_summary) { create :disposable_income_summary, :with_everything }
        it 'has the expected keysin the response structure' do
          expected_keys = %i[
            outgoings
            childcare_allowance
            dependant_allowance
            maintenance_allowance
            gross_housing_costs
            housing_benefit
            net_housing_costs
            total_outgoings_and_allowances
            total_disposable_income
            lower_threshold
            upper_threshold
            assessment_result
            income_contribution
          ]
          expect(subject.keys).to eq expected_keys
          outgoings_keys = %i[childcare_costs housing_costs maintenance_costs]
          expect(subject[:outgoings].keys).to eq outgoings_keys
        end

        it 'calls payment decorator once for each outgoing' do
          expected_count = disposable_income_summary.outgoings.count
          expect(PaymentDecorator).to receive(:new).and_return(double('outgoing_payent')).exactly(expected_count).times
          subject
        end
      end
    end
  end
end
