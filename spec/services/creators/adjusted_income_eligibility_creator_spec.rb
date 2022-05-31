require "rails_helper"

module Creators
  RSpec.describe AdjustedIncomeEligibilityCreator do

    let(:crime_assessment) { create :assessment, :criminal, :with_gross_income_summary }
    let(:summary) { crime_assessment.gross_income_summary }

    around do |example|
      travel_to Date.new(2022, 5, 20)
      example.run
      travel_back
    end

    subject(:creator) { described_class.call(crime_assessment) }

    describe "#call" do
      it "creates one eligibility record" do
        expect { creator }.to change { Eligibility::AdjustedIncome.count }.by(1)
      end

      it "creates a record with the expected thresholds" do
        creator
        elig = summary.crime_eligibilities.first
        expect(elig.upper_threshold).to eq 22325
        expect(elig.lower_threshold).to eq 12475
        expect(elig.assessment_result).to eq "pending"
      end
    end
  end
end
