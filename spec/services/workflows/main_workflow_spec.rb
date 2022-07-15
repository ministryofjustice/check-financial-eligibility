require "rails_helper"

module Workflows
  RSpec.describe ".call" do
    let(:assessment) { create :assessment, applicant: }

    context "applicant is passported" do
      let(:applicant) { create :applicant, :with_qualifying_benefits }

      subject(:workflow_call) { MainWorkflow.call(assessment) }

      it "calls PassportedWorkflow" do
        allow(Assessors::MainAssessor).to receive(:call)
        expect(PassportedWorkflow).to receive(:call).with(assessment)
        workflow_call
      end

      it "calls MainAssessor" do
        allow(PassportedWorkflow).to receive(:call)
        expect(Assessors::MainAssessor).to receive(:call).with(assessment)
        workflow_call
      end
    end

    context "applicant is not passported" do
      let(:applicant) { create :applicant, :without_qualifying_benefits }

      subject(:workflow_call) { MainWorkflow.call(assessment) }

      it "calls PassportedWorkflow" do
        allow(Assessors::MainAssessor).to receive(:call)
        expect(NonPassportedWorkflow).to receive(:call).with(assessment)
        workflow_call
      end

      it "calls MainAssessor" do
        allow(NonPassportedWorkflow).to receive(:call)
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
               version: "5",
               applicant:
      end
      let(:applicant) { create :applicant, :without_qualifying_benefits }

      subject(:workflow_call) { MainWorkflow.call(assessment) }

      context "without an proceeding types" do
        it "raises" do
          expect {
            workflow_call
          }.to raise_error RuntimeError, "Proceeding Types not created"
        end
      end

      context "with proceeding types" do
        before { create_list :proceeding_type, 2, assessment: }

        it "Populates proceeding types with thresholds" do
          expect(Utilities::ProceedingTypeThresholdPopulator).to receive(:call).with(assessment)

          allow(Creators::EligibilitiesCreator).to receive(:call).with(assessment)
          allow(NonPassportedWorkflow).to receive(:call).with(assessment)
          allow(Assessors::MainAssessor).to receive(:call).with(assessment)
          allow(RemarkGenerators::Orchestrator).to receive(:call).with(assessment)

          workflow_call
        end

        it "creates the eligibility records" do
          expect(Creators::EligibilitiesCreator).to receive(:call).with(assessment)

          allow(Utilities::ProceedingTypeThresholdPopulator).to receive(:call).with(assessment)
          allow(NonPassportedWorkflow).to receive(:call).with(assessment)
          allow(Assessors::MainAssessor).to receive(:call).with(assessment)
          allow(RemarkGenerators::Orchestrator).to receive(:call).with(assessment)

          workflow_call
        end
      end
    end
  end
end
