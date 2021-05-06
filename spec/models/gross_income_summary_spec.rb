require 'rails_helper'

RSpec.describe GrossIncomeSummary do
  let(:assessment) { create :assessment }
  let(:gross_income_summary) do
    create :gross_income_summary, assessment: assessment
  end

  describe 'housing_benefit_payments' do
    context 'no state benefits belonging to gross income summary' do
      it 'returns an empty array' do
        expect(gross_income_summary.state_benefits).to be_empty
        expect(gross_income_summary.housing_benefit_payments).to be_empty
      end
    end

    context 'no state benefit of type housing_benefit' do
      it 'returns an empty array' do
        state_benefit_type = create :state_benefit_type, label: 'not_housing_benefit'
        create :state_benefit, state_benefit_type: state_benefit_type, gross_income_summary: gross_income_summary
        expect(gross_income_summary.housing_benefit_payments).to be_empty
      end
    end

    context 'housing benefit payments exist' do
      it 'returns all the payments belonging to the housing state benefit' do
        other_state_benefit_type = create :state_benefit_type, label: 'not_housing_benefit'
        other_state_benefit = create :state_benefit, state_benefit_type: other_state_benefit_type, gross_income_summary: gross_income_summary
        create :state_benefit_payment, state_benefit: other_state_benefit

        housing_benefit_type = create :state_benefit_type, label: 'housing_benefit'
        housing_benefit = create :state_benefit, state_benefit_type: housing_benefit_type, gross_income_summary: gross_income_summary
        housing_benefit_payments = create_list :state_benefit_payment, 3, state_benefit: housing_benefit

        expect(gross_income_summary.housing_benefit_payments).to match_array housing_benefit_payments
      end
    end
  end
end
