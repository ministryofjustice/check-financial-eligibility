require "rails_helper"

module Decorators
  module V4
    RSpec.describe GrossIncomeResultDecorator do
      let(:unlimited) { 999_999_999_999.0 }
      let(:ptc_results) do
        {
          DA002: [unlimited, "eligible"],
          DA003: [unlimited, "eligible"],
          SE013: [8_000, "ineligible"],
        }
      end
      let(:ptcs) { ptc_results.keys }
      let(:assessment) { create :assessment, proceeding_type_codes: ptcs }
      let(:summary) { create :gross_income_summary, assessment: assessment, total_gross_income: 16_615.40 }
      let(:expected_hash) do
        {
          total_gross_income: 16_615.40,
          proceeding_types: [
            {
              ccms_code: "DA002",
              upper_threshold: 999_999_999_999.0,
              result: "eligible",
            },
            {
              ccms_code: "DA003",
              upper_threshold: 999_999_999_999.0,
              result: "eligible",
            },
            {
              ccms_code: "SE013",
              upper_threshold: 8_000.0,
              result: "ineligible",
            },
          ],
        }
      end

      subject(:decorator) { described_class.new(assessment).as_json }

      before do
        ptc_results.each do |ptc, thresh_and_result|
          threshold, result = thresh_and_result
          create :gross_income_eligibility, gross_income_summary: summary, upper_threshold: threshold, assessment_result: result, proceeding_type_code: ptc
        end
      end

      it "generates the expected hash" do
        expect(decorator).to eq expected_hash
      end
    end
  end
end
