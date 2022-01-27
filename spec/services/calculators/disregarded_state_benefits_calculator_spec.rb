require 'rails_helper'

module Calculators
  RSpec.describe DisregardedStateBenefitsCalculator do
    let(:assessment) { create :assessment, :with_disposable_income_summary, :with_gross_income_summary }
    let(:disposable_income_summary) { assessment.disposable_income_summary }
    let(:included_state_benefit_type) { create :state_benefit_type, :benefit_included }
    let(:excluded_state_benefit_type) { create :state_benefit_type, :benefit_excluded }
    let(:gross_income_summary) { assessment.gross_income_summary }

    subject { described_class.call(disposable_income_summary) }

    context 'no state benefit payments' do
      it ' should return zero' do
        expect(subject).to eq 0
      end
    end

    context 'only included state benefit payments' do
      before do
        create :state_benefit, :with_monthly_payments, state_benefit_type: included_state_benefit_type, gross_income_summary: gross_income_summary
      end
      it 'should return zero' do
        expect(subject).to eq 0
      end
    end

    context 'has excluded state benefit payments' do
      before do
        create :state_benefit, :with_monthly_payments, state_benefit_type: excluded_state_benefit_type, gross_income_summary: gross_income_summary
        create :state_benefit, :with_monthly_payments, state_benefit_type: included_state_benefit_type, gross_income_summary: gross_income_summary
        create :state_benefit, :with_monthly_payments, state_benefit_type: excluded_state_benefit_type, gross_income_summary: gross_income_summary
      end
      it 'should return value x 2' do
        expect(subject).to eq 176.6
      end
    end
  end
end
