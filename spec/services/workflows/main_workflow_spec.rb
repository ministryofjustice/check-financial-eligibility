require "rails_helper"

module Workflows
  RSpec.describe ".call" do
    let(:assessment) { create :assessment, applicant: applicant }

    context "applicant is passported" do
      let(:applicant) { create :applicant, :with_qualifying_benefits }

      subject { MainWorkflow.call(assessment) }

      it "calls PassportedWorkflow" do
        allow(Assessors::MainAssessor).to receive(:call)
        expect(PassportedWorkflow).to receive(:call).with(assessment)
        subject
      end

      it "calls MainAssessor" do
        allow(PassportedWorkflow).to receive(:call)
        expect(Assessors::MainAssessor).to receive(:call).with(assessment)
        subject
      end
    end

    context "applicant is not passported" do
      let(:applicant) { create :applicant, :without_qualifying_benefits }

      subject { MainWorkflow.call(assessment) }

      it "calls PassportedWorkflow" do
        allow(Assessors::MainAssessor).to receive(:call)
        expect(NonPassportedWorkflow).to receive(:call).with(assessment)
        subject
      end

      it "calls MainAssessor" do
        allow(NonPassportedWorkflow).to receive(:call)
        expect(Assessors::MainAssessor).to receive(:call).with(assessment)
        subject
      end
    end
  end
end
