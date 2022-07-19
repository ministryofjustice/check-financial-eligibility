require "rails_helper"

module Creators
  RSpec.describe CapitalEligibilityCreator do
    let(:summary) { assessment.capital_summary }

    around do |example|
      travel_to Date.new(2021, 4, 20)
      example.run
      travel_back
    end

    subject(:creator) { described_class.call(assessment) }

    context "version 4" do
      let(:assessment) { create :assessment, :with_capital_summary, proceeding_type_codes: codes }

      before { mock_lfa_responses }

      context "domestic abuse only" do
        let(:codes) { %w[DA001] }

        it "creates one eligibility record" do
          expect { creator }.to change(Eligibility::Capital, :count).by(1)
        end

        it "creates a record with the expected thresholds" do
          creator
          elig = summary.eligibilities.find_by(proceeding_type_code: codes.first)
          expect(elig.lower_threshold).to eq 3_000.0
          expect(elig.upper_threshold).to eq 999_999_999_999.0
          expect(elig.assessment_result).to eq "pending"
        end
      end

      context "non_domestic_abuse only" do
        let(:codes) { %w[SE013] }

        it "creates one eligibility record" do
          expect { creator }.to change(Eligibility::Capital, :count).by(1)
        end

        it "creates a record with the expected thresholds" do
          creator
          elig = summary.eligibilities.find_by(proceeding_type_code: codes.first)
          expect(elig.lower_threshold).to eq 3_000.0
          expect(elig.upper_threshold).to eq 8_000.0
          expect(elig.assessment_result).to eq "pending"
        end
      end

      context "multiple_proceeding_types" do
        let(:codes) { %w[DA001 DA005 SE003] }

        it "creates one eligibility record for each proceeding type" do
          expect { creator }.to change(Eligibility::Capital, :count).by(codes.size)
        end
      end
    end

    context "version 5" do
      let(:assessment) { create :assessment, :with_capital_summary, :version_5 }
      let(:eligibilities) { assessment.capital_summary.eligibilities }
      let(:proceeding_types) { assessment.proceeding_types }

      before do
        create :proceeding_type, :with_waived_thresholds, assessment: assessment, ccms_code: "DA002"
        create :proceeding_type, :with_unwaived_thresholds, assessment: assessment, ccms_code: "SE013"
        creator
      end

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
    end
  end
end
