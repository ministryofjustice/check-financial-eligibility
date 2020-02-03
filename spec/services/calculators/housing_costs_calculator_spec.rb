require 'rails_helper'

module Calculators
  RSpec.describe HousingCostsCalculator do
    let(:assessment) { create :assessment, :with_disposable_income_summary }
    let(:housing_cost_above_cap) { 600.00 }
    let(:housing_cost_below_cap) { 530.00 }
    let(:housing_cost_cap) { 545.00 }

    before do
      [2.months.ago, 1.month.ago, Date.today].each do |date|
        create :housing_cost_outgoing,
               disposable_income_summary: assessment.disposable_income_summary,
               payment_date: date,
               amount: housing_cost_amount
      end
    end

    subject { described_class.call(assessment) }

    context 'applicant has dependants' do
      let(:housing_cost_amount) { housing_cost_above_cap }
      before { create :dependant, assessment: assessment }
      context 'actual housing costs higher than cap' do
        it 'returns the uncapped value' do
          expect(subject).to eq housing_cost_above_cap
        end
      end
    end

    context 'applicant has no dependants' do
      context 'actual housing costs lower than cap' do
        let(:housing_cost_amount) { housing_cost_below_cap }
        it 'returns the actual housing costs' do
          expect(subject).to eq housing_cost_below_cap
        end
      end

      context 'actual housing costs higher than cap' do
        let(:housing_cost_amount) { housing_cost_above_cap }
        it 'returns the capped value' do
          expect(subject).to eq housing_cost_cap
        end
      end
    end
  end
end
