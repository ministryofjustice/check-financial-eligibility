require "rails_helper"

module Assessors
  RSpec.describe AdjustedIncomeAssessor do
    describe ".call" do
      let(:assessment) { gross_income_summary.assessment }
      let(:gross_income_summary) { create :gross_income_summary, :with_employment }

      before do
        create :adjusted_income_eligibility,
                gross_income_summary:,
               lower_threshold:,
               upper_threshold:
      end

      subject(:assessor) { described_class.call(assessment) }

      context "adjusted income below lower threshold" do
        # need to pass in gross income
        let(:lower_threshold) { 12475 }
        let(:upper_threshold) { 22325 }

        it "is eligible" do
          assessor
          expect(gross_income_summary.crime_summarized_assessment_result).to eq :eligible
        end
      end

      # test logic with dependants

    #   context "disposable income equal to lower threshold" do
    #     let(:total_disposable_income) { 316.0 }
    #     let(:lower_threshold) { 316.0 }
    #     let(:upper_threshold) { 733.0 }

    #     it "is eligible" do
    #       assessor
    #       expect(disposable_income_summary.summarized_assessment_result).to eq :eligible
    #     end

    #     it "does call the income contribution calculator and updates the contribution with the result" do
    #       expect(Calculators::IncomeContributionCalculator).not_to receive(:call)
    #       assessor
    #       expect(disposable_income_summary.income_contribution).to eq 0.0
    #     end
    #   end

    #   context "disposable income above lower threshold and below upper threshold" do
    #     let(:total_disposable_income) { 340.20 }
    #     let(:lower_threshold) { 316.0 }
    #     let(:upper_threshold) { 733.0 }

    #     before { allow(Calculators::IncomeContributionCalculator).to receive(:call).and_return(125.94) }

    #     it "is eligible with a contribution" do
    #       assessor
    #       expect(disposable_income_summary.summarized_assessment_result).to eq :contribution_required
    #     end

    #     it "updates the contribution with the result from the Calculators::IncomeContributionCalculator" do
    #       assessor
    #       expect(disposable_income_summary.income_contribution).to eq 125.94
    #     end
    #   end

    #   context "disposable income equal to upper threshold" do
    #     let(:total_disposable_income) { 733.0 }
    #     let(:lower_threshold) { 316.0 }
    #     let(:upper_threshold) { 733.0 }

    #     it "is ineligible" do
    #       assessor
    #       expect(disposable_income_summary.summarized_assessment_result).to eq :contribution_required
    #     end

    #     it "does call the income contribution calculator" do
    #       expect(Calculators::IncomeContributionCalculator).to receive(:call).and_call_original
    #       assessor
    #       expect(disposable_income_summary.income_contribution).to eq 203.75
    #     end
    #   end

    #   context "disposable income above upper threshold" do
    #     let(:total_disposable_income) { 734.0 }
    #     let(:lower_threshold) { 316.0 }
    #     let(:upper_threshold) { 733.0 }

    #     it "is ineligible" do
    #       assessor
    #       expect(disposable_income_summary.summarized_assessment_result).to eq :ineligible
    #     end

    #     it "does not call the income contribution calculator" do
    #       expect(Calculators::IncomeContributionCalculator).not_to receive(:call)
    #       assessor
    #       expect(disposable_income_summary.income_contribution).to eq 0.0
    #     end
    #   end
    end
  end
end