require "rails_helper"

module Assessors
  RSpec.describe AdjustedIncomeAssessor do
    describe ".call" do
      let(:assessment) { gross_income_summary.assessment }
      let(:gross_income_summary) { create :gross_income_summary, total_gross_income: }
      let(:lower_threshold) { 12_475.00 }
      let(:upper_threshold) { 22_325.00 }

      before do
        create :adjusted_income_eligibility,
               lower_threshold:,
               upper_threshold:,
               gross_income_summary:
      end

      subject(:assessor) { described_class.call(assessment) }

      context "no dependants" do
        context "gross income below lower threshold" do
          let(:total_gross_income) { 10_000.00 }

          it "is eligible" do
            assessor
            expect(gross_income_summary.crime_summarized_assessment_result).to eq :eligible
            expect(gross_income_summary.adjusted_income).to eq 10_000.00
          end
        end

        context "gross income equal to lower threshold" do
          let(:total_gross_income) { lower_threshold }

          it "is eligible" do
            assessor
            expect(gross_income_summary.crime_summarized_assessment_result).to eq :eligible
            expect(gross_income_summary.adjusted_income).to eq 12_475.00
          end
        end

        context "gross income above lower threshold and below upper threshold" do
          let(:total_gross_income) { 17_554.36 }

          it "a full means test is required" do
            assessor
            expect(gross_income_summary.crime_summarized_assessment_result).to eq :full_means_test_required
            expect(gross_income_summary.adjusted_income).to eq 17_554.36
          end
        end

        context "gross income equal to upper threshold" do
          let(:total_gross_income) { upper_threshold }

          it "a full means test is required" do
            assessor
            expect(gross_income_summary.crime_summarized_assessment_result).to eq :full_means_test_required
            expect(gross_income_summary.adjusted_income).to eq 22_325.00
          end
        end

        context "gross income above upper threshold" do
          let(:total_gross_income) { 31_824.78 }

          it "is ineligible" do
            assessor
            expect(gross_income_summary.crime_summarized_assessment_result).to eq :ineligible
            expect(gross_income_summary.adjusted_income).to eq 31_824.78
          end
        end
      end

      context "with dependants" do
        context "dependant renders adjusted income below lower threshold" do
          let(:total_gross_income) { 15_000.0 }
          let(:dependant) { create :dependant, :crime_dependant, :aged15 }

          it "is eligible" do
            set_dependant(assessment, dependant)

            assessor
            expect(gross_income_summary.crime_summarized_assessment_result).to eq :eligible
          end
        end

        context "dependant renders adjusted income between lower and upper threshold" do
          let(:total_gross_income) { 23_000.00 }
          let(:dependant) { create :dependant, :crime_dependant, :under15 }

          it "is eligible" do
            set_dependant(assessment, dependant)

            assessor
            expect(gross_income_summary.crime_summarized_assessment_result).to eq :full_means_test_required
          end
        end

        context "adjusted income above upper threshold, even with dependant" do
          let(:total_gross_income) { 40_000.00 }
          let(:dependant) { create :dependant, :crime_dependant, :aged15 }

          it "is eligible" do
            set_dependant(assessment, dependant)

            assessor
            expect(gross_income_summary.crime_summarized_assessment_result).to eq :ineligible
          end
        end

        def set_dependant(record, dependant)
          record.update!(dependants: [dependant])
        end
      end
    end
  end
end
