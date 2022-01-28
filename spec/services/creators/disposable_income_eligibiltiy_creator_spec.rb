require "rails_helper"

module Creators
  RSpec.describe DisposableIncomeEligibilityCreator do
    let(:assessment) { create :assessment, :with_disposable_income_summary, proceeding_type_codes: codes }
    let(:summary) { assessment.disposable_income_summary }

    before { mock_lfa_responses }

    around do |example|
      travel_to Date.new(2021, 4, 20)
      example.run
      travel_back
    end

    subject { described_class.call(assessment) }

    context "domestic abuse only" do
      let(:codes) { ["DA001"] }

      it "creates one eligibility record" do
        expect { subject }.to change { Eligibility::DisposableIncome.count }.by(1)
      end

      it "creates a record with the expected thresholds" do
        subject
        elig = summary.eligibilities.find_by(proceeding_type_code: codes.first)
        expect(elig.lower_threshold).to eq 315.0
        expect(elig.upper_threshold).to eq 999_999_999_999.0
        expect(elig.assessment_result).to eq "pending"
      end
    end

    context "non_domestic_abuse only" do
      let(:codes) { ["SE013"] }

      it "creates one eligibility record" do
        expect { subject }.to change { Eligibility::DisposableIncome.count }.by(1)
      end

      it "creates a record with the expected thresholds" do
        subject
        elig = summary.eligibilities.find_by(proceeding_type_code: codes.first)
        expect(elig.lower_threshold).to eq 315.0
        expect(elig.upper_threshold).to eq 733.0
        expect(elig.assessment_result).to eq "pending"
      end
    end

    context "multiple_proceeding_types" do
      let(:codes) { %w[DA001 DA005 SE003] }

      it "creates one eligibility record for each proceeding type" do
        expect { subject }.to change { Eligibility::DisposableIncome.count }.by(codes.size)
      end
    end
  end
end
