require "rails_helper"

module Creators
  RSpec.describe GrossIncomeEligibilityCreator do
    let(:summary) { assessment.gross_income_summary }

    around do |example|
      travel_to Date.new(2021, 4, 20)
      example.run
      travel_back
    end

    subject(:creator) { described_class.call(assessment) }

    context "version 4" do
      before { mock_lfa_responses }

      let(:assessment) { create :assessment, :with_gross_income_summary, proceeding_type_codes: codes }

      context "domestic abuse only" do
        let(:codes) { %w[DA001] }

        it "creates one eligibility record" do
          expect { creator }.to change(Eligibility::GrossIncome, :count).by(1)
        end

        it "creates a record with the expected thresholds" do
          creator
          elig = summary.eligibilities.find_by(proceeding_type_code: codes.first)
          expect(elig.upper_threshold).to eq 999_999_999_999.0
          expect(elig.assessment_result).to eq "pending"
        end
      end

      context "non_domestic_abuse only" do
        let(:codes) { %w[SE013] }

        it "creates one eligibility record" do
          expect { creator }.to change(Eligibility::GrossIncome, :count).by(1)
        end

        context "two children" do
          before do
            create_list(:dependant, 2, :child_relative, assessment:)
            create_list(:dependant, 4, :adult_relative, assessment:)
          end

          it "creates a record with no uplifted threshold" do
            creator
            elig = summary.eligibilities.find_by(proceeding_type_code: codes.first)
            expect(elig.upper_threshold).to eq 2657.0
            expect(elig.assessment_result).to eq "pending"
          end
        end

        context "six children" do
          let(:expected_threshold) { 2657 + (222 * 2) }

          before do
            create_list :dependant, 6, :child_relative, assessment:
          end

          it "creates a record with the uplifted threshold" do
            creator
            elig = summary.eligibilities.find_by(proceeding_type_code: codes.first)
            expect(elig.upper_threshold).to eq expected_threshold
            expect(elig.assessment_result).to eq "pending"
          end
        end
      end

      context "multiple_proceeding_types" do
        let(:codes) { %w[DA001 DA005 SE003] }

        it "creates one eligibility record for each proceeding type" do
          expect { creator }.to change(Eligibility::GrossIncome, :count).by(codes.size)
        end
      end
    end

    context "version 5" do
      let(:assessment) { create :assessment, :with_gross_income_summary, :version_5 }
      let(:eligibilities) { assessment.gross_income_summary.eligibilities }
      let(:proceeding_types) { assessment.proceeding_types }

      before do
        create :proceeding_type, :with_waived_thresholds, assessment: assessment, ccms_code: "DA002"
        create :proceeding_type, :with_unwaived_thresholds, assessment:, ccms_code: "SE013"
      end

      it "creates a capital eligibility record for each proceeding type" do
        creator
        expect(eligibilities.size).to eq 2
        expect(eligibilities.map(&:proceeding_type_code)).to match_array(proceeding_types.map(&:ccms_code))
      end

      it "creates eligibility record with correct waived thresholds" do
        creator
        pt = proceeding_types.find_by!(ccms_code: "DA002", client_involvement_type: "A")
        elig = eligibilities.find_by!(proceeding_type_code: "DA002")
        expect(elig.upper_threshold).to eq pt.gross_income_upper_threshold
        expect(elig.lower_threshold).to be_nil
      end

      context "no dependants" do
        it "creates eligibility record with correct un-waived thresholds" do
          creator
          pt = proceeding_types.find_by!(ccms_code: "SE013", client_involvement_type: "Z")
          elig = eligibilities.find_by!(proceeding_type_code: "SE013")
          expect(elig.upper_threshold).to eq pt.gross_income_upper_threshold
          expect(elig.lower_threshold).to be_nil
        end
      end

      context "two children" do
        before do
          create_list(:dependant, 2, :child_relative, assessment:)
          create_list(:dependant, 4, :adult_relative, assessment:)
        end

        it "creates eligibility record with no dependant uplift on threshold" do
          creator
          pt = proceeding_types.find_by!(ccms_code: "SE013", client_involvement_type: "Z")
          elig = eligibilities.find_by!(proceeding_type_code: "SE013")
          expect(elig.upper_threshold).to eq pt.gross_income_upper_threshold
          expect(elig.lower_threshold).to be_nil
        end
      end

      context "six children" do
        let(:expected_uplift) { 222 * 2 }

        before do
          create_list :dependant, 6, :child_relative, assessment:
        end

        it "creates a record with the uplifted threshold" do
          creator
          pt = proceeding_types.find_by!(ccms_code: "SE013", client_involvement_type: "Z")
          elig = eligibilities.find_by!(proceeding_type_code: "SE013")
          expect(elig.upper_threshold).to eq pt.gross_income_upper_threshold + expected_uplift
          expect(elig.assessment_result).to eq "pending"
        end
      end
    end
  end
end
