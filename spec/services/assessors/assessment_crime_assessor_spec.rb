require "rails_helper"

module Assessors
  RSpec.describe AssessmentCrimeAssessor do
    let(:assessment) do
      create :assessment,
             :criminal,
             :with_gross_income_summary_and_crime_eligibility,
             :with_crime_eligibility,
             :with_applicant
    end
    let(:adjusted_income_eligibility) { assessment.gross_income_summary.crime_eligibility }
    let(:assessment_eligibility) { assessment.crime_eligibility }

    describe ".call" do
      describe "successful result" do
        context "initial means test" do
          it "updates the assessment eligibility record with the correct result" do
            adjusted_income_eligibility.update!(assessment_result: "eligible")
            described_class.call(assessment)

            expect(assessment_eligibility.assessment_result).to eq("eligible")
          end
        end
      end

      describe "unsuccessful result" do
        context "initial means test" do
          it "raises the expected error" do
            adjusted_income_eligibility.update!(assessment_result: "pending")

            expect(test_error).to eq("Assessment not complete: Adjusted Income assessment still pending")
          end
        end
      end
    end

    def test_error
      begin
        described_class.call(assessment)
      rescue StandardError => e
        raise "Unexpected exception: #{e.class}" unless e.is_a?(Assessors::AssessmentCrimeAssessor::CrimeAssessmentError)

        return e.message
      end
      nil
    end
  end
end
