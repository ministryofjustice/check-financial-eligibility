require "rails_helper"

module Creators
  RSpec.describe EligibilitiesCreator do
    let(:assessment) { create :assessment }

    describe ".call" do
      it "calls an eligibility creator for each type of summary record" do
        expect(GrossIncomeEligibilityCreator).to receive(:call).with(assessment)
        expect(DisposableIncomeEligibilityCreator).to receive(:call).with(assessment)
        expect(CapitalEligibilityCreator).to receive(:call).with(assessment)

        described_class.call(assessment)
      end
    end
  end
end
