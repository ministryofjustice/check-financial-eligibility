require "rails_helper"

module Assessors
  RSpec.describe MainAssessor do
    let(:assessment) do
      create :assessment,
             :with_capital_summary,
             :with_gross_income_summary,
             :with_disposable_income_summary,
             :with_applicant,
             proceedings: [%w[DA003 A], %w[SE014 Z]]
    end

    subject(:assessor) { described_class.call(assessment) }

    context "AssessmentProceedingTypeAssessor" do
      it "calls AssessmentProceedingTypeAssessor for each proceeding type code" do
        expect(AssessmentProceedingTypeAssessor).to receive(:call).with(assessment, "DA003")
        expect(AssessmentProceedingTypeAssessor).to receive(:call).with(assessment, "SE014")
        assessor
      end
    end

    context "result summarizer" do
      before do
        create :assessment_eligibility, assessment: assessment, proceeding_type_code: "DA003", assessment_result: "eligible"
        create :assessment_eligibility, assessment: assessment, proceeding_type_code: "SE014", assessment_result: "ineligible"

        allow(AssessmentProceedingTypeAssessor).to receive(:call).with(assessment, "DA003")
        allow(AssessmentProceedingTypeAssessor).to receive(:call).with(assessment, "SE014")
      end

      it "calls the Results summarizer to update the assessment result" do
        expect(Utilities::ResultSummarizer).to receive(:call).with(%w[eligible ineligible]).and_call_original

        assessor
        expect(assessment.assessment_result).to eq "partially_eligible"
      end
    end
  end
end
