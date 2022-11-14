require "rails_helper"

module Collators
  RSpec.describe OutgoingsCollator do
    let(:assessment) { create :assessment }

    subject(:collator) do
      described_class.call(submission_date: assessment.submission_date,
                           dependants: assessment.dependants,
                           person: assessment.applicant,
                           gross_income_summary: assessment.gross_income_summary,
                           disposable_income_summary: assessment.disposable_income_summary)
    end

    describe ".call" do
      it "calls all the collators and calculators" do
        expect(Collators::ChildcareCollator).to receive(:call).exactly(1)
        expect(Collators::DependantsAllowanceCollator).to receive(:call).exactly(1)
        expect(Collators::MaintenanceCollator).to receive(:call).with(assessment.disposable_income_summary).exactly(1)
        expect(Collators::HousingCostsCollator).to receive(:call).exactly(1)
        expect(Collators::LegalAidCollator).to receive(:call).with(assessment.disposable_income_summary).exactly(1)
        collator
      end
    end
  end
end
