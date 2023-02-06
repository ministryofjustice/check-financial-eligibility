require "rails_helper"

module Decorators
  module V5
    RSpec.describe CapitalResultDecorator do
      let(:unlimited) { 999_999_999_999.0 }
      let(:assessment) { create :assessment, proceedings: pr_hash }
      let(:pt_results) do
        {
          DA003: [3000, unlimited, "eligible"],
          SE014: [3000, 8000, "ineligible"],
        }
      end
      let(:pr_hash) { [%w[DA003 A], %w[SE014 Z]] }
      let(:summary) do
        create :capital_summary,
               assessment:,
               total_liquid: 9_355.23,
               total_non_liquid: 12_553.22,
               total_property: 835_500,
               total_mortgage_allowance: 750_000,
               total_capital: 24_000,
               pensioner_capital_disregard: 10_000,
               subject_matter_of_dispute_disregard: 3_000,
               capital_contribution: 0.0,
               assessed_capital: 9_355,
               combined_assessed_capital: 12_000
      end
      let(:subtotals) { PersonCapitalSubtotals.new(total_vehicle: 3500) }

      let(:expected_result) do
        {
          total_liquid: 9_355.23,
          total_non_liquid: 12_553.22,
          total_vehicle: 3500,
          total_property: 835_500,
          total_mortgage_allowance: 750_000,
          total_capital: 24_000,
          pensioner_capital_disregard: 10_000,
          subject_matter_of_dispute_disregard: 3_000,
          capital_contribution: 0.0,
          assessed_capital: 9_355,
          proceeding_types: [
            {
              ccms_code: "DA003",
              client_involvement_type: "A",
              lower_threshold: 3_000.0,
              upper_threshold: 999_999_999_999.0,
              result: "eligible",
            },
            {
              ccms_code: "SE014",
              client_involvement_type: "Z",
              lower_threshold: 3_000.0,
              upper_threshold: 8_000.0,
              result: "ineligible",
            },
          ],
          combined_assessed_capital: 12_000.0,
          combined_capital_contribution: 0,
        }
      end

      before do
        pt_results.each do |ptc, details|
          lower_threshold, upper_threshold, result = details
          create :capital_eligibility,
                 capital_summary: summary,
                 proceeding_type_code: ptc,
                 lower_threshold:,
                 upper_threshold:,
                 assessment_result: result
        end
      end

      subject(:decorator) { described_class.new(assessment.capital_summary, subtotals).as_json }

      describe "#as_json" do
        it "returns the expected structure" do
          expect(decorator).to eq expected_result
        end
      end
    end
  end
end
