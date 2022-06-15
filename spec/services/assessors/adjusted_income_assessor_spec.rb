require "rails_helper"

module Assessors
  RSpec.describe AdjustedIncomeAssessor do
    describe ".call" do
      let(:assessment) { gross_income_summary.assessment }
      let(:gross_income_summary) { create :gross_income_summary, total_gross_income: }
      let(:lower_threshold) { 12475 }
      let(:upper_threshold) { 22325 }

      before do
        create :adjusted_income_eligibility,
                lower_threshold: lower_threshold,
                upper_threshold: upper_threshold,
                gross_income_summary:
      end

      subject(:assessor) { described_class.call(assessment) }

      context "gross income below lower threshold" do
        let(:total_gross_income) { 10000 }

        it "is eligible" do
          assessor
          expect(gross_income_summary.crime_summarized_assessment_result).to eq :eligible
        end
      end

      # test logic with dependants

      context "gross income equal to lower threshold" do
        let(:total_gross_income) { lower_threshold }

        it "is eligible" do
          assessor
          expect(gross_income_summary.crime_summarized_assessment_result).to eq :eligible
        end
      end

      context "gross income above lower threshold and below upper threshold" do
        let(:total_gross_income) { 17554.36 }

        it "a full means test is required" do
          assessor
          expect(gross_income_summary.crime_summarized_assessment_result).to eq :full_means_test_required
        end
      end

      context "gross income equal to upper threshold" do
        let(:total_gross_income) { upper_threshold }

        it "a full means test is required" do
          assessor
          expect(gross_income_summary.crime_summarized_assessment_result).to eq :full_means_test_required
        end
      end

      context "gross income above upper threshold" do
        let(:total_gross_income) { 31824.78 }

        it "is ineligible" do
          assessor
          expect(gross_income_summary.crime_summarized_assessment_result).to eq :ineligible
        end
      end
    end
  end
end