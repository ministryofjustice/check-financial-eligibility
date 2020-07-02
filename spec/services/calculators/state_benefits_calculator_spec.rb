require 'rails_helper'

module Calculators
  RSpec.describe StateBenefitsCalculator do
    before { create :bank_holiday }
    let(:assessment) { create :assessment, :with_gross_income_summary }
    let(:gross_income_summary) { assessment.gross_income_summary }
    subject { described_class.call(assessment) }

    context 'no state benefit records' do
      it 'leaves the monthly state benefit value as zero' do
        subject
        expect(gross_income_summary.reload.monthly_state_benefits).to eq 0.0
      end
    end

    context 'state benefit records exist' do
      let(:state_benefit_type_included) { create :state_benefit_type, exclude_from_gross_income: false }
      let!(:weekly_state_benefits) do
        create :state_benefit,
               :with_weekly_payments,
               gross_income_summary: gross_income_summary,
               state_benefit_type: state_benefit_type_included
      end
      context 'weekly payments' do
        it 'returns correct total monthly state benefits' do
          expect(subject).to eq 216.67
        end
      end

      context 'monthly and weekly payments' do
        let(:another_state_benefit_type_included) { create :state_benefit_type, exclude_from_gross_income: false }
        let!(:monthly_state_benefits) do
          create :state_benefit,
                 :with_monthly_payments,
                 gross_income_summary: gross_income_summary,
                 state_benefit_type: another_state_benefit_type_included
        end
        it 'returns correct sum of both monthly and weekly benefits' do
          expect(subject).to eq(216.67 + 88.3)
        end
      end
      context 'mixture of included and excluded benefits' do
        let(:state_benefit_type_excluded) { create :state_benefit_type, exclude_from_gross_income: true }
        let!(:monthly_state_benefits) do
          create :state_benefit,
                 :with_monthly_payments,
                 gross_income_summary: gross_income_summary,
                 state_benefit_type: state_benefit_type_excluded
        end
        it 'returns correct sum amounts of only included benefits' do
          expect(subject).to eq(216.67)
        end
      end
    end
  end
end
