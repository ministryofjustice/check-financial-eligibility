require 'rails_helper'

module Calculators
  RSpec.describe DisposableIncomeCalculator do
    describe '.call' do
      let(:assessment) { create :assessment }
      let!(:disposable_income_summary) do
        create :disposable_income_summary,
               assessment: assessment,
               childcare: 456.77,
               dependant_allowance: 874.47,
               maintenance: 255,
               net_housing_costs: 1277.44
      end
      let!(:gross_income_summary) { create :gross_income_summary, assessment: assessment, total_gross_income: total_gross_income }

      subject { described_class.call(assessment) }

      before { subject }

      context 'thresholds' do
        let(:total_gross_income) { 3000 }
        it 'populates the thresholds' do
          expect(disposable_income_summary.reload.upper_threshold).to eq 733
          expect(disposable_income_summary.lower_threshold).to eq 315
        end
      end

      context 'total disposable income' do
        context 'allowances/expenses less that total gross income' do
          let(:total_gross_income) { 3000 }
          it 'updates the total disposable income to the difference between gross income and expenses/allowances' do
            expect(disposable_income_summary.reload.total_disposable_income).to eq 136.32
          end
        end

        context 'allowances/expenses greater than total gross income' do
          let(:total_gross_income) { 500 }
          it 'updates the total disposable income to the difference between gross income and expenses/allowances' do
            expect(disposable_income_summary.reload.total_disposable_income).to eq 0.0
          end
        end
      end
    end
  end
end
