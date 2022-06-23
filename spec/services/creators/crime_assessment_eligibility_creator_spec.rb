require "rails_helper"

module Creators
  RSpec.describe CrimeAssessmentEligibilityCreator do
    describe ".call" do
      let(:assessment) { create :assessment, :criminal }

      subject(:creator) { described_class.call(assessment) }

      it "creates one crime assessment eligibility record" do
        expect { creator }.to change { Eligibility::CrimeAssessment.count }.by(1)
      end

      it "sets the assessment result to pending" do
        creator
        expect(assessment.crime_eligibility.assessment_result).to eq "pending"
      end

      it "sets all thresholds to nil" do
        creator
        expect(assessment.crime_eligibility.upper_threshold).to eq nil
        expect(assessment.crime_eligibility.lower_threshold).to eq nil
      end
    end
  end
end