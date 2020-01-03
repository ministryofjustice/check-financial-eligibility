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

    context 'no state benefit of type housing_benfit' do
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

        expect(gross_income_summary.housing_benefit_payments).to eq housing_benefit_payments
      end
    end
  end

  describe '#summarise!' do
    let(:data) do
      {
        upper_threshold: Faker::Number.decimal
      }
    end

    subject { gross_income_summary.summarise! }

    before do
      allow(Collators::GrossIncomeCollator).to receive(:call).with(assessment).and_return(data)
      subject
      gross_income_summary.reload
    end

    it 'persists the data' do
      data.each do |method, value|
        expect(gross_income_summary.__send__(method).to_d).to eq(value.to_d)
      end
    end
  end
end
