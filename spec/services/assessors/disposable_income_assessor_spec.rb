require 'rails_helper'

module Assessors
  RSpec.describe DisposableIncomeAssessor do
    describe '.call' do
      let(:assessment) { disposable_income_summary.assessment }

      subject { described_class.call(assessment) }
      context 'disposable income below lower threshold' do
        let(:disposable_income_summary) { create :disposable_income_summary, total_disposable_income: 310, lower_threshold: 316, upper_threshold: 733 }
        it 'is eligible' do
          subject
          expect(disposable_income_summary.assessment_result).to eq 'eligible'
        end

        it 'does not call the income contribution calculator' do
          expect(Calculators::IncomeContributionCalculator).not_to receive(:call)
          subject
          expect(disposable_income_summary.income_contribution).to eq 0.0
        end
      end

      context 'disposable income equal to lower threshold' do
        let(:disposable_income_summary) { create :disposable_income_summary, total_disposable_income: 316.0, lower_threshold: 316, upper_threshold: 733 }
        it 'is eligible' do
          subject
          expect(disposable_income_summary.assessment_result).to eq 'eligible'
        end

        it 'does call the income contribution calculator and updates the contribution with the result' do
          expect(Calculators::IncomeContributionCalculator).not_to receive(:call)
          subject
          expect(disposable_income_summary.income_contribution).to eq 0.0
        end
      end

      context 'disposable income above lower threshold and below upper threshold' do
        let(:disposable_income_summary) { create :disposable_income_summary, total_disposable_income: 340.20, lower_threshold: 316, upper_threshold: 733 }

        before { expect(Calculators::IncomeContributionCalculator).to receive(:call).and_return(125.94) }

        it 'is eligible with a contribution' do
          subject
          expect(disposable_income_summary.assessment_result).to eq 'contribution_required'
        end

        it 'updates the contribution with the result from the Calculators::IncomeContributionCalculator' do
          subject
          expect(disposable_income_summary.income_contribution).to eq 125.94
        end
      end

      context 'disposable income equal to upper threshold' do
        let(:disposable_income_summary) { create :disposable_income_summary, total_disposable_income: 733.0, lower_threshold: 316, upper_threshold: 733 }
        it 'is ineligible' do
          subject
          expect(disposable_income_summary.assessment_result).to eq 'not_eligible'
        end

        it 'does not call the income contribution calculator' do
          expect(Calculators::IncomeContributionCalculator).not_to receive(:call)
          subject
          expect(disposable_income_summary.income_contribution).to eq 0.0
        end
      end

      context 'disposable income above upper threshold' do
        let(:disposable_income_summary) { create :disposable_income_summary, total_disposable_income: 734, lower_threshold: 316, upper_threshold: 733 }
        it 'is ineligible' do
          subject
          expect(disposable_income_summary.assessment_result).to eq 'not_eligible'
        end

        it 'does not call the income contribution calculator' do
          expect(Calculators::IncomeContributionCalculator).not_to receive(:call)
          subject
          expect(disposable_income_summary.income_contribution).to eq 0.0
        end
      end
    end
  end
end
