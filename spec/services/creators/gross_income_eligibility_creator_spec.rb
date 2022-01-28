require "rails_helper"

module Creators
  RSpec.describe GrossIncomeEligibilityCreator do
    before(:each) { mock_lfa_responses }

    let(:assessment) { create :assessment, :with_gross_income_summary, proceeding_type_codes: codes }
    let(:summary) { assessment.gross_income_summary }

    around do |example|
      travel_to Date.new(2021, 4, 20)
      example.run
      travel_back
    end

    subject { described_class.call(assessment) }

    context "domestic abuse only" do
      let(:codes) { ["DA001"] }

      it "creates one eligibility record" do
        expect { subject }.to change { Eligibility::GrossIncome.count }.by(1)
      end

      it "creates a record with the expected thresholds" do
        subject
        elig = summary.eligibilities.find_by(proceeding_type_code: codes.first)
        expect(elig.upper_threshold).to eq 999_999_999_999.0
        expect(elig.assessment_result).to eq "pending"
      end
    end

    context "non_domestic_abuse only" do
      let(:codes) { ["SE013"] }

      it "creates one eligibility record" do
        expect { subject }.to change { Eligibility::GrossIncome.count }.by(1)
      end

      context "two children" do
        before do
          create_list :dependant, 2, :child_relative, assessment: assessment
          create_list :dependant, 4, :adult_relative, assessment: assessment
        end

        it "creates a record with no uplifted threshold" do
          subject
          elig = summary.eligibilities.find_by(proceeding_type_code: codes.first)
          expect(elig.upper_threshold).to eq 2657.0
          expect(elig.assessment_result).to eq "pending"
        end
      end

      context "six children" do
        let(:expected_threshold) { 2657 + (222 * 2) }

        before do
          create_list :dependant, 6, :child_relative, assessment: assessment
        end

        it "creates a record with the uplifted threshold" do
          subject
          elig = summary.eligibilities.find_by(proceeding_type_code: codes.first)
          expect(elig.upper_threshold).to eq expected_threshold
          expect(elig.assessment_result).to eq "pending"
        end
      end
    end

    context "multiple_proceeding_types" do
      let(:codes) { %w[DA001 DA005 SE003] }

      it "creates one eligibility record for each proceeding type" do
        expect { subject }.to change { Eligibility::GrossIncome.count }.by(codes.size)
      end
    end
  end
end
