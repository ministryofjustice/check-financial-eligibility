require "rails_helper"

module Calculators
  RSpec.describe MultipleEmploymentsCalculator, :vcr do
    let(:assessment) { create :assessment, :with_gross_income_summary, :with_disposable_income_summary }

    before do
      create_list :employment, 2, assessment:
    end

    it "sets gross employment income to zero" do
      described_class.call(assessment:,
                           employments: assessment.employments,
                           disposable_income_summary: assessment.disposable_income_summary,
                           gross_income_summary: assessment.gross_income_summary)
      expect(assessment.gross_income_summary.gross_employment_income).to eq 0
    end

    it "sets benefits in kind to zero" do
      described_class.call(assessment:,
                           employments: assessment.employments,
                           disposable_income_summary: assessment.disposable_income_summary,
                           gross_income_summary: assessment.gross_income_summary)
      expect(assessment.gross_income_summary.benefits_in_kind).to eq 0
    end

    it "sets employment income deductions to zero" do
      described_class.call(assessment:,
                           employments: assessment.employments,
                           disposable_income_summary: assessment.disposable_income_summary,
                           gross_income_summary: assessment.gross_income_summary)
      expect(assessment.disposable_income_summary.employment_income_deductions).to eq 0
    end

    it "sets tax to zero" do
      described_class.call(assessment:,
                           employments: assessment.employments,
                           disposable_income_summary: assessment.disposable_income_summary,
                           gross_income_summary: assessment.gross_income_summary)
      expect(assessment.disposable_income_summary.tax).to eq 0
    end

    it "sets national insurance to zero" do
      described_class.call(assessment:,
                           employments: assessment.employments,
                           disposable_income_summary: assessment.disposable_income_summary,
                           gross_income_summary: assessment.gross_income_summary)
      expect(assessment.disposable_income_summary.national_insurance).to eq 0
    end

    it "sets fixed employment allowance to 45" do
      described_class.call(assessment:,
                           employments: assessment.employments,
                           disposable_income_summary: assessment.disposable_income_summary,
                           gross_income_summary: assessment.gross_income_summary)
      expect(assessment.disposable_income_summary.fixed_employment_allowance).to eq(-45)
    end
  end
end
