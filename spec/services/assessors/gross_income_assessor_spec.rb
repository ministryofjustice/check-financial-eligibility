require "rails_helper"

module Assessors
  RSpec.describe GrossIncomeAssessor do
    let(:assessment) { create :assessment, :with_gross_income_summary }
    let(:gross_income_summary) { assessment.gross_income_summary }

    describe ".call" do
      subject(:assessor) do
        described_class.call(eligibilities: gross_income_summary.eligibilities,
                             total_gross_income:)
      end

      context "gross income has been summarised" do
        context "monthly income below upper threshold" do
          let(:total_gross_income) { 2_400 }

          it "is eligible" do
            create :gross_income_eligibility, gross_income_summary:, upper_threshold: 2_567
            assessor
            expect(gross_income_summary.summarized_assessment_result).to eq :eligible
          end
        end

        context "monthly income equals upper threshold" do
          let(:total_gross_income) { 2_567 }

          it "is not eligible" do
            create :gross_income_eligibility, gross_income_summary:, upper_threshold: 2_567
            assessor
            expect(gross_income_summary.summarized_assessment_result).to eq :ineligible
          end
        end

        context "monthly income above upper threshold" do
          let(:total_gross_income) { 2_600 }

          it "is not eligible" do
            create :gross_income_eligibility, gross_income_summary:, upper_threshold: 2_567
            assessor
            expect(gross_income_summary.summarized_assessment_result).to eq :ineligible
          end
        end
      end
    end
  end
end
