require "rails_helper"

module Creators
  RSpec.describe DisposableIncomeEligibilityCreator do
    let(:summary) { assessment.disposable_income_summary }

    around do |example|
      travel_to Date.new(2021, 4, 20)
      example.run
      travel_back
    end

    subject(:creator) { described_class.call(assessment) }

    context "version 5" do
      let(:assessment) { create :assessment, :with_disposable_income_summary, proceedings: proceeding_hash }
      let(:eligibilities) { assessment.disposable_income_summary.eligibilities }
      let(:proceeding_types) { assessment.proceeding_types }
      let(:proceeding_hash) { [%w[DA002 A], %w[SE013 Z]] }

      before { creator }

      it "creates a capital eligibility record for each proceeding type" do
        expect(eligibilities.size).to eq 2
        expect(eligibilities.map(&:proceeding_type_code)).to match_array(proceeding_types.map(&:ccms_code))
      end

      it "creates eligibilty record with correct waived thresholds" do
        pt = proceeding_types.find_by!(ccms_code: "DA002", client_involvement_type: "A")
        elig = eligibilities.find_by!(proceeding_type_code: "DA002")
        expect(elig.upper_threshold).to eq pt.disposable_income_upper_threshold
        expect(elig.lower_threshold).to eq 315.0
      end

      it "creates eligibilty record with correct un-waived thresholds" do
        pt = proceeding_types.find_by!(ccms_code: "SE013", client_involvement_type: "Z")
        elig = eligibilities.find_by!(proceeding_type_code: "SE013")
        expect(elig.upper_threshold).to eq pt.disposable_income_upper_threshold
        expect(elig.lower_threshold).to eq 315.0
      end
    end
  end
end
