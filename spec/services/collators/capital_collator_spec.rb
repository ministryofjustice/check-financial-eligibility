require "rails_helper"

module Collators
  RSpec.describe CapitalCollator do
    let(:assessment) { create :assessment, :with_capital_summary, :with_disposable_income_summary, :with_applicant }
    let(:request_hash) { AssessmentRequestFixture.ruby_hash }
    let(:submission_date) { assessment.submission_date }
    let(:capital_summary) { assessment.capital_summary }
    let(:today) { Date.new(2019, 4, 2) }
    let(:pcd_value) { 0 }
    let(:smod_value) { 0 }
    let(:level_of_help) { "controlled" }

    describe ".call" do
      subject(:collator) do
        described_class.call submission_date: assessment.submission_date,
                             capital_summary: assessment.capital_summary,
                             pensioner_capital_disregard: pcd_value,
                             maximum_subject_matter_of_dispute_disregard: smod_value,
                             level_of_help:
      end

      it "always returns a hash" do
        expect(collator).to be_a PersonCapitalSubtotals
      end

      context "liquid capital" do
        it "calls LiquidCapitalAssessment and updates capital summary with the result" do
          allow(Assessors::LiquidCapitalAssessor).to receive(:call).and_return(145.83)
          expect(collator.total_liquid).to eq 145.83
        end
      end

      context "property_assessment" do
        it "instantiates and calls the Property Assessment service" do
          property_result = Calculators::PropertyCalculator::Result.new(assessed_equity: 23_000.0, smod_applied: 0)
          allow(Calculators::PropertyCalculator).to receive(:call).and_return([property_result])
          expect(collator.total_property).to eq 23_000.0
        end
      end

      context "vehicle assessment" do
        it "instantiates and calls the Vehicle Assesment service" do
          allow(Assessors::VehicleAssessor).to receive(:call).and_return([OpenStruct.new(value: 2_500.0)])
          expect(collator.total_vehicle).to eq 2_500.0
        end
      end

      context "non_liquid_capital_assessment" do
        it "instantiates and calls NonLiquidCapitalAssessment" do
          allow(Assessors::NonLiquidCapitalAssessor).to receive(:call).and_return(500)
          expect(collator.total_non_liquid).to eq 500.0
        end
      end

      context "summarization of result_fields" do
        let(:pcd_value) { 100_000 }

        it "summarizes the results it gets from the subservices" do
          property_result = Calculators::PropertyCalculator::Result.new(assessed_equity: 23_000.0, smod_applied: 0)

          allow(Calculators::PropertyCalculator).to receive(:call).and_return([property_result])

          allow(Assessors::LiquidCapitalAssessor).to receive(:call).and_return(145.83)
          allow(Assessors::NonLiquidCapitalAssessor).to receive(:call).and_return(500)
          allow(Assessors::VehicleAssessor).to receive(:call).and_return([OpenStruct.new(value: 2_500.0)])

          expect(collator.total_liquid).to eq 145.83
          expect(collator.total_non_liquid).to eq 500
          expect(collator.total_vehicle).to eq 2_500
          expect(collator.total_property).to eq 23_000
          expect(collator.total_mortgage_allowance).to eq 999_999_999_999
          expect(collator.total_capital).to eq 26_145.83
          expect(collator.pensioner_capital_disregard).to eq 100_000
          expect(collator.subject_matter_of_dispute_disregard).to eq 0
          expect(collator.assessed_capital).to eq(-0.0)
          expect(collator.pensioner_disregard_applied).to eq(26_145.83)
        end
      end
    end
  end
end
