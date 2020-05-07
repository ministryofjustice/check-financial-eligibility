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
        let!(:gross_income_summary) { create :gross_income_summary, assessment: disposable_income_summary.assessment }
        it 'has the expected keys in the response structure' do
          expected_keys = %i[
            monthly_outgoing_equivalents
            childcare_allowance
            deductions
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
          outgoings_keys = %i[child_care maintenance_out rent_or_mortgage legal_aid]
          expect(subject[:monthly_outgoing_equivalents].keys).to eq outgoings_keys
        end
      end
    end
  end
end
