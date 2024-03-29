require "rails_helper"

module Collators
  RSpec.describe OutgoingsCollator do
    let(:assessment) { create :assessment }

    subject(:collator) { described_class.call(assessment) }

    describe ".call" do
      it "calls all the collators and calculators" do
        expect(Collators::ChildcareCollator).to receive(:call).with(assessment).exactly(1)
        expect(Collators::DependantsAllowanceCollator).to receive(:call).with(assessment).exactly(1)
        expect(Collators::MaintenanceCollator).to receive(:call).with(assessment).exactly(1)
        expect(Collators::HousingCostsCollator).to receive(:call).with(assessment).exactly(1)
        expect(Collators::LegalAidCollator).to receive(:call).with(assessment).exactly(1)
        collator
      end
    end
  end
end
