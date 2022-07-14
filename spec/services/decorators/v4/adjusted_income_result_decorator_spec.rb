require "rails_helper"

module Decorators
  module V4
    RSpec.describe AdjustedIncomeResultDecorator do
      let(:assessment) { create :assessment, :criminal }
      let(:summary) { create :gross_income_summary, assessment:, total_gross_income: 10_615.40, adjusted_income: 11_615.40 }
      let(:expected_hash) do
        {
          adjusted_income: 11_615.40,
          lower_threshold: 12_475.00,
          upper_threshold: 22_325.00,
          result: "eligible",
        }
      end

      before do
        create :adjusted_income_eligibility, gross_income_summary: summary, lower_threshold: 12_475.00, upper_threshold: 22_325.00, assessment_result: "eligible"
      end

      subject(:decorator) { described_class.new(assessment).as_json }

      it "generates the expected hash" do
        expect(decorator).to eq expected_hash
      end
    end
  end
end
