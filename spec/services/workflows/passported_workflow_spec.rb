require "rails_helper"

module Workflows
  RSpec.describe PassportedWorkflow do
    let(:assessment) do
      create :assessment,
             :with_disposable_income_summary,
             :with_gross_income_summary_and_eligibilities,
             :with_capital_summary_and_eligibilities,
             proceedings: [%w[DA003 A], %w[SE014 Z]],
             applicant:
    end
    let(:applicant) { create :applicant, :with_qualifying_benefits }
    let(:capital_summary) { assessment.capital_summary }
    let(:gross_income_summary) { assessment.gross_income_summary }
    let(:capital_data) do
      PersonCapitalSubtotals.new(
        total_liquid: 45.36,
        total_non_liquid: 14_000.02,
        total_vehicle: 500.0,
        total_mortgage_allowance: 100_000.0,
        total_property: 35_000,
        pensioner_capital_disregard: 90_000,
        total_capital: 14_045.38,
        assessed_capital: 0.0,
        capital_contribution: 0.0,
      )
    end

    describe ".call" do
      subject(:workflow_call) { described_class.call(assessment) }

      it "calls Capital collator and return some data" do
        allow(Collators::CapitalCollator).to receive(:call).and_return(capital_data)
        expect(Collators::CapitalCollator).to receive(:call)
        result = workflow_call
        expect(result.capital_subtotals.applicant_capital_subtotals).to eq capital_data
        expect(result.capital_subtotals.combined_assessed_capital).to eq capital_data.assessed_capital
      end

      it "calls CapitalAssessor and updates capital summary record with result" do
        allow(Collators::CapitalCollator).to receive(:call).and_return(capital_data)
        expect(Collators::CapitalCollator).to receive(:call)
        expect(Assessors::CapitalAssessor).to receive(:call).and_call_original
        workflow_call
        expect(capital_summary.summarized_assessment_result).to eq :eligible
      end
    end
  end
end
