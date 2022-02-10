require "rails_helper"

module Assessors
  RSpec.describe DisposableIncomeAssessor do
    describe ".call" do
      let(:assessment) { disposable_income_summary.assessment }
      let(:disposable_income_summary) { create :disposable_income_summary, total_disposable_income: total_disposable_income }

      before do
        create :disposable_income_eligibility,
               disposable_income_summary: disposable_income_summary,
               proceeding_type_code: assessment.proceeding_type_codes.first,
               lower_threshold: lower_threshold,
               upper_threshold: upper_threshold
      end

      subject(:assessor) { described_class.call(assessment) }

      context "disposable income below lower threshold" do
        let(:total_disposable_income) { 310.0 }
        let(:lower_threshold) { 316.0 }
        let(:upper_threshold) { 733.0 }

        it "is eligible" do
          assessor
          expect(disposable_income_summary.summarized_assessment_result).to eq :eligible
        end

        it "does not call the income contribution calculator" do
          expect(Calculators::IncomeContributionCalculator).not_to receive(:call)
          assessor
          expect(disposable_income_summary.income_contribution).to eq 0.0
        end
      end

      context "disposable income equal to lower threshold" do
        let(:total_disposable_income) { 316.0 }
        let(:lower_threshold) { 316.0 }
        let(:upper_threshold) { 733.0 }

        it "is eligible" do
          assessor
          expect(disposable_income_summary.summarized_assessment_result).to eq :eligible
        end

        it "does call the income contribution calculator and updates the contribution with the result" do
          expect(Calculators::IncomeContributionCalculator).not_to receive(:call)
          assessor
          expect(disposable_income_summary.income_contribution).to eq 0.0
        end
      end

      context "disposable income above lower threshold and below upper threshold" do
        let(:total_disposable_income) { 340.20 }
        let(:lower_threshold) { 316.0 }
        let(:upper_threshold) { 733.0 }

        before { allow(Calculators::IncomeContributionCalculator).to receive(:call).and_return(125.94) }

        it "is eligible with a contribution" do
          assessor
          expect(disposable_income_summary.summarized_assessment_result).to eq :contribution_required
        end

        it "updates the contribution with the result from the Calculators::IncomeContributionCalculator" do
          assessor
          expect(disposable_income_summary.income_contribution).to eq 125.94
        end
      end

      context "disposable income equal to upper threshold" do
        let(:total_disposable_income) { 733.0 }
        let(:lower_threshold) { 316.0 }
        let(:upper_threshold) { 733.0 }

        it "is ineligible" do
          assessor
          expect(disposable_income_summary.summarized_assessment_result).to eq :contribution_required
        end

        it "does call the income contribution calculator" do
          expect(Calculators::IncomeContributionCalculator).to receive(:call).and_call_original
          assessor
          expect(disposable_income_summary.income_contribution).to eq 203.75
        end
      end

      context "disposable income above upper threshold" do
        let(:total_disposable_income) { 734.0 }
        let(:lower_threshold) { 316.0 }
        let(:upper_threshold) { 733.0 }

        it "is ineligible" do
          assessor
          expect(disposable_income_summary.summarized_assessment_result).to eq :ineligible
        end

        it "does not call the income contribution calculator" do
          expect(Calculators::IncomeContributionCalculator).not_to receive(:call)
          assessor
          expect(disposable_income_summary.income_contribution).to eq 0.0
        end
      end
    end
  end
end
