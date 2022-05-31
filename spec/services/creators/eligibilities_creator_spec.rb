require "rails_helper"

module Creators
  RSpec.describe EligibilitiesCreator do
    let(:assessment) { create :assessment }
    let(:crime_assessment) { create :assessment, :criminal }

    describe ".call" do
      context "civil assessment" do
        it "calls an eligibility creator for each type of summary record" do
          expect(GrossIncomeEligibilityCreator).to receive(:call).with(assessment)
          expect(DisposableIncomeEligibilityCreator).to receive(:call).with(assessment)
          expect(CapitalEligibilityCreator).to receive(:call).with(assessment)
  
          described_class.call(assessment)
        end
      end

      context "crime assessment" do
        it "calls an eligibility creator for each type of summary record" do
          expect(AdjustedIncomeEligibilityCreator).to receive(:call).with(crime_assessment)
  
          described_class.call(crime_assessment)
        end
      end


    end
  end
end
