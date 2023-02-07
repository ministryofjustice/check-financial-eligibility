require "rails_helper"

module Workflows
  RSpec.describe ".call" do
    let(:proceedings_hash) { [%w[DA003 A], %w[SE013 I]] }
    let(:bank_holiday_response) { %w[2015-01-01 2015-04-03 2015-04-06] }
    let(:assessment) do
      create :assessment,
             :with_everything,
             proceedings: proceedings_hash,
             applicant:
    end

    before do
      allow(GovukBankHolidayRetriever).to receive(:dates).and_return(bank_holiday_response)
    end

    context "applicant is passported" do
      let(:applicant) { create :applicant, :with_qualifying_benefits }

      subject(:workflow_call) { MainWorkflow.call(assessment) }

      it "calls PassportedWorkflow" do
        allow(Assessors::MainAssessor).to receive(:call)
        allow(PassportedWorkflow).to receive(:call).with(assessment).and_return(CalculationOutput.new)
        workflow_call
      end

      it "calls MainAssessor" do
        allow(PassportedWorkflow).to receive(:call).and_return(CalculationOutput.new)
        expect(Assessors::MainAssessor).to receive(:call).with(assessment)
        workflow_call
      end
    end

    context "applicant is not passported" do
      let(:applicant) { create :applicant, :without_qualifying_benefits }

      subject(:workflow_call) { MainWorkflow.call(assessment) }

      it "calls PassportedWorkflow" do
        allow(Assessors::MainAssessor).to receive(:call)
        allow(NonPassportedWorkflow).to receive(:call).with(assessment).and_return(CalculationOutput.new)
        workflow_call
      end

      it "calls MainAssessor" do
        allow(NonPassportedWorkflow).to receive(:call).and_return(CalculationOutput.new)
        expect(Assessors::MainAssessor).to receive(:call).with(assessment)
        workflow_call
      end
    end

    context "version 5" do
      let(:assessment) do
        create :assessment,
               :with_capital_summary,
               :with_capital_summary,
               :with_gross_income_summary,
               :with_disposable_income_summary,
               proceedings: proceedings_hash,
               version: "5",
               applicant:
      end
      let(:applicant) { create :applicant, :without_qualifying_benefits }

      subject(:workflow_call) { MainWorkflow.call(assessment) }

      context "with proceeding types" do
        it "Populates proceeding types with thresholds" do
          expect(Utilities::ProceedingTypeThresholdPopulator).to receive(:call).with(assessment)

          allow(Creators::EligibilitiesCreator).to receive(:call).with(assessment)
          allow(NonPassportedWorkflow).to receive(:call).with(assessment).and_return(CalculationOutput.new)
          allow(Assessors::MainAssessor).to receive(:call).with(assessment)
          allow(RemarkGenerators::Orchestrator).to receive(:call).with(assessment, nil)

          workflow_call
        end

        it "creates the eligibility records" do
          expect(Creators::EligibilitiesCreator).to receive(:call).with(assessment)

          allow(Utilities::ProceedingTypeThresholdPopulator).to receive(:call).with(assessment)
          allow(NonPassportedWorkflow).to receive(:call).with(assessment).and_return(CalculationOutput.new)
          allow(Assessors::MainAssessor).to receive(:call).with(assessment)
          allow(RemarkGenerators::Orchestrator).to receive(:call).with(assessment, nil)

          workflow_call
        end
      end
    end
  end
end
