require 'rails_helper'

module Decorators
  module V4
    RSpec.describe Decorators::V4::CapitalResultDecorator do
      let(:unlimited) { 999_999_999_999.0 }
      let(:assessment) { create :assessment, proceeding_type_codes: pt_results.keys }
      let(:pt_results) do
        {
          DA001: [3000, unlimited, 'eligible'],
          SE013: [3000, 8000, 'ineligible']
        }
      end
      let(:summary) do
        create :capital_summary,
               assessment: assessment,
               total_liquid: 9_355.23,
               total_non_liquid: 12_553.22,
               total_vehicle: 3500,
               total_property: 835_500,
               total_mortgage_allowance: 750_000,
               total_capital: 24_000,
               pensioner_capital_disregard: 10_000,
               capital_contribution: 0.0,
               assessed_capital: 9_355
      end

      let(:expected_result) do
        {
          total_liquid: 9_355.23,
          total_non_liquid: 12_553.22,
          total_vehicle: 3500,
          total_property: 835_500,
          total_mortgage_allowance: 750_000,
          total_capital: 24_000,
          pensioner_capital_disregard: 10_000,
          capital_contribution: 0.0,
          assessed_capital: 9_355,
          proceeding_types: [
            {
              ccms_code: 'DA001',
              lower_threshold: 3_000.0,
              upper_threshold: 999_999_999_999.0,
              result: 'eligible'
            },
            {
              ccms_code: 'SE013',
              lower_threshold: 3_000.0,
              upper_threshold: 8_000.0,
              result: 'ineligible'
            }
          ]
        }
      end

      before do
        pt_results.each do |ptc, details|
          lower_threshold, upper_threshold, result = details
          create :capital_eligibility,
                 capital_summary: summary,
                 proceeding_type_code: ptc,
                 lower_threshold: lower_threshold,
                 upper_threshold: upper_threshold,
                 assessment_result: result
        end
      end

      subject { described_class.new(assessment).as_json }

      describe '#as_json' do
        it 'returns the expected structure' do
          expect(subject).to eq expected_result
        end
      end
    end
  end
end
