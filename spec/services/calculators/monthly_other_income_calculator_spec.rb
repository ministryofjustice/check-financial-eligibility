require 'rails_helper'

module Calculators
  RSpec.describe MonthlyOtherIncomeCalculator do
    let(:assessment) { create :assessment }
    let(:gross_income_summary) { assessment.gross_income_summary }
    let!(:source1) { create :other_income_source, gross_income_summary: gross_income_summary }
    let!(:source2) { create :other_income_source, gross_income_summary: gross_income_summary }
    let!(:payment11) { create :other_income_payment, other_income_source: source1, payment_date: 1.month.ago, amount: 125.44 }
    let!(:payment12) { create :other_income_payment, other_income_source: source1, payment_date: Date.today, amount: 125.44 }
    let!(:payment21) { create :other_income_payment, other_income_source: source2, payment_date: 1.month.ago, amount: 202.12 }
    let!(:payment22) { create :other_income_payment, other_income_source: source2, payment_date: Date.today, amount: 201.44 }

    describe '.call' do
      before { described_class.call(assessment.id) }

      it 'updates each source record with the total monthly income' do
        expect(source1.reload.monthly_income).to eq 125.44
        expect(source2.reload.monthly_income).to eq 201.78
      end

      it 'updates the gross income summary with total monthly other income' do
        expect(gross_income_summary.reload.monthly_other_income).to eq 327.22
      end
    end
  end
end
