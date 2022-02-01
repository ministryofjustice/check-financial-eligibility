require "rails_helper"

module Workflows
  RSpec.describe PassportedWorkflow do
    let(:assessment) do
      create :assessment,
             :with_gross_income_summary_and_eligibilities,
             :with_capital_summary_and_eligibilities,
             applicant: applicant
    end
    let(:applicant) { create :applicant, :with_qualifying_benefits }
    let(:capital_summary) { assessment.capital_summary }
    let(:gross_income_summary) { assessment.gross_income_summary }

    describe ".call" do
      subject(:workflow_call) { described_class.call(assessment) }

      it "calls Capital collator and updates capital summary record" do
        expect(Collators::CapitalCollator).to receive(:call).with(assessment).and_return(capital_data)
        workflow_call
        expect(capital_summary.reload).to have_matching_attributes(capital_data)
      end

      it "calls CapitalAssessor and updates capital summary record with result" do
        expect(Collators::CapitalCollator).to receive(:call).with(assessment).and_return(capital_data)
        expect(Assessors::CapitalAssessor).to receive(:call).with(assessment).and_call_original
        workflow_call
        expect(capital_summary.summarized_assessment_result).to eq :eligible
      end

      def capital_data
        {
          total_liquid: 45.36,
          total_non_liquid: 14_000.02,
          total_vehicle: 500.0,
          total_mortgage_allowance: 100_000.0,
          total_property: 35_000,
          pensioner_capital_disregard: 90_000,
          total_capital: 14_045.38,
          assessed_capital: 0.0,
          lower_threshold: 3_000.0,
          upper_threshold: 8_000.0,
          capital_contribution: 0.0,
        }
      end
    end
  end
end
