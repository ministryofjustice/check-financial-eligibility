require "rails_helper"

module Calculators
  RSpec.describe SubjectMatterOfDisputeDisregardCalculator do
    subject(:value) do
      described_class.new(submission_date: assessment.submission_date,
                          capital_summary: assessment.capital_summary).value
    end

    let(:assessment) { create :assessment, capital_summary: }
    let(:capital_summary) do
      create :capital_summary,
             vehicles: [vehicle],
             capital_items: [capital_item],
             properties: [property]
    end
    let(:vehicle) { create :vehicle, subject_matter_of_dispute: false }
    let(:capital_item) { create :liquid_capital_item, subject_matter_of_dispute: false }
    let(:property) { create :property, subject_matter_of_dispute: false }
    let(:threshold_value) { 10_000 }

    before do
      allow(Threshold).to receive(:value_for).and_return(threshold_value)
    end

    describe "#value" do
      context "without any SMOD assets" do
        it "returns 0" do
          expect(value).to eq 0
        end
      end

      context "with a SMOD vehicle worth less than the disregard" do
        let(:vehicle) { create :vehicle, assessed_value: 1_000, subject_matter_of_dispute: true }

        it "returns the value of the vehicle" do
          expect(value).to eq 1_000
        end
      end

      context "with a SMOD property worth less than the disregard" do
        let(:property) { create :property, assessed_equity: 5_000, subject_matter_of_dispute: true }

        it "returns the value of the property" do
          expect(value).to eq 5_000
        end
      end

      context "with a SMOD capital item worth less than the disregard" do
        let(:capital_item) { create :liquid_capital_item, value: 3_000, subject_matter_of_dispute: true }

        it "returns the value of the capital item" do
          expect(value).to eq 3_000
        end
      end

      context "with multiple SMOD assets worth less than the disregard" do
        let(:capital_item) { create :liquid_capital_item, value: 3_000, subject_matter_of_dispute: true }
        let(:vehicle) { create :vehicle, assessed_value: 1_000, subject_matter_of_dispute: true }
        let(:property) { create :property, assessed_equity: 5_000, subject_matter_of_dispute: true }

        it "returns the combined value of the assets" do
          expect(value).to eq 9_000
        end
      end

      context "with multiple SMOD assets worth more than the disregard" do
        let(:capital_item) { create :liquid_capital_item, value: 3_000, subject_matter_of_dispute: true }
        let(:vehicle) { create :vehicle, assessed_value: 1_000, subject_matter_of_dispute: true }
        let(:property) { create :property, assessed_equity: 9_000, subject_matter_of_dispute: true }

        it "returns the disregard value" do
          expect(value).to eq 10_000
        end
      end

      context "if there is no valid threshold provided" do
        let(:capital_item) { create :liquid_capital_item, value: 3_000, subject_matter_of_dispute: true }
        let(:vehicle) { create :vehicle, assessed_value: 1_000, subject_matter_of_dispute: true }
        let(:property) { create :property, assessed_equity: 9_000, subject_matter_of_dispute: true }
        let(:threshold_value) { nil }

        it "raises an exception" do
          expect { value }.to raise_error RuntimeError
        end
      end
    end
  end
end
