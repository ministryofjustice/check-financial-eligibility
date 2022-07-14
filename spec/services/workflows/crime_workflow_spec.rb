require "rails_helper"

module Workflows
  RSpec.describe CrimeWorkflow do
    let(:assessment) do
      create :assessment,
             :criminal,
             :with_gross_income_summary_and_crime_eligibility,
             applicant:
    end
    let(:applicant) { create :applicant }
    let(:gross_income_summary) { assessment.gross_income_summary }

    describe ".call" do
      subject(:workflow_call) { described_class.call(assessment) }

      it "collates gross income and assesses adjusted income" do
        expect(Collators::GrossIncomeCollator).to receive(:call).with(assessment)
        expect(Assessors::AdjustedIncomeAssessor).to receive(:call).with(assessment)
        workflow_call
      end
    end
  end
end
