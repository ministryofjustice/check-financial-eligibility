require "rails_helper"

module Creators
  RSpec.describe CapitalEligibilityCreator do
    let(:summary) { assessment.capital_summary }

    around do |example|
      travel_to Date.new(2022, 4, 20)
      example.run
      travel_back
    end

    subject(:creator) { described_class.call(assessment) }

    context "version 5" do
      let(:assessment) { create :assessment, :with_capital_summary, proceedings: [%w[DA002 A], %w[SE013 Z]] }
      let(:eligibilities) { assessment.capital_summary.eligibilities }
      let(:proceeding_types) { assessment.proceeding_types }

      before { creator }

      it "creates a capital eligibility record for each proceeding type" do
        expect(eligibilities.size).to eq 2
        expect(eligibilities.map(&:proceeding_type_code)).to match_array(proceeding_types.map(&:ccms_code))
      end

      it "creates eligibility record with correct waived thresholds" do
        pt = proceeding_types.find_by!(ccms_code: "DA002", client_involvement_type: "A")
        elig = eligibilities.find_by!(proceeding_type_code: "DA002")
        expect(elig.upper_threshold).to eq pt.capital_upper_threshold
        expect(elig.lower_threshold).to eq 3_000.0
      end

      it "creates eligibility record with correct un-waived thresholds" do
        pt = proceeding_types.find_by!(ccms_code: "SE013", client_involvement_type: "Z")
        elig = eligibilities.find_by!(proceeding_type_code: "SE013")
        expect(elig.upper_threshold).to eq pt.capital_upper_threshold
        expect(elig.lower_threshold).to eq 3_000.0
      end

      context "for controlled work" do
        let(:assessment) do
          create :assessment,
                 :with_capital_summary,
                 proceedings: [%w[DA002 A], %w[SE013 Z]],
                 level_of_representation: "controlled"
        end

        it "uses controlled lower threshold" do
          pt = proceeding_types.find_by!(ccms_code: "SE013", client_involvement_type: "Z")
          elig = eligibilities.find_by!(proceeding_type_code: "SE013")
          expect(elig.upper_threshold).to eq pt.capital_upper_threshold
          expect(elig.lower_threshold).to eq 8_000.0
        end
      end
    end
  end
end
