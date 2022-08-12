require "rails_helper"

module Creators
  RSpec.describe AssessmentEligibilityCreator do
    describe ".call" do
      let(:codes) { [%w[DA001 A], %w[SE013 Z], %w[SE004 W]] }
      let(:assessment) { create :assessment, proceedings: codes }

      subject(:creator) { described_class.call(assessment) }

      it "creates an assessment eligibilty record for each proceeding type code" do
        expect { creator }.to change(Eligibility::Assessment, :count).by(3)
        expect(assessment.eligibilities.map(&:proceeding_type_code)).to match_array codes.map(&:first)
      end

      it "sets the assessment result to pending on all of them" do
        creator
        expect(assessment.eligibilities.map(&:assessment_result).uniq).to eq %w[pending]
      end

      it "sets all thresholds to nil" do
        creator
        expect(assessment.eligibilities.map(&:upper_threshold).uniq).to eq [nil]
        expect(assessment.eligibilities.map(&:lower_threshold).uniq).to eq [nil]
      end
    end
  end
end
