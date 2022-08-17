require "rails_helper"

module Decorators
  module V5
    RSpec.describe DisposableIncomeResultDecorator, :vcr do
      let(:unlimited) { 999_999_999_999.0 }
      let(:assessment) { create :assessment, :with_gross_income_summary, proceedings: proceeding_hash }
      let(:summary) do
        create :disposable_income_summary,
               assessment:,
               dependant_allowance: 220.21,
               gross_housing_costs: 990.42,
               housing_benefit: 440.21,
               net_housing_costs: 550.21,
               maintenance_out_all_sources: 330.21,
               total_outgoings_and_allowances: 660.21,
               total_disposable_income: 732.55,
               income_contribution: 75
      end
      let(:employment1) { create :employment, :with_monthly_payments, assessment: }
      let(:employment2) { create :employment, :with_monthly_payments, assessment: }
      let(:codes) { pt_results.keys }
      let(:pt_results) do
        {
          DA003: [315, unlimited, "contribution_required"],
          DA005: [315, unlimited, "contribution_required"],
          SE003: [315, 733, "ineligible"],
          SE014: [315, 733, "ineligible"],
        }
      end
      let(:proceeding_hash) { [%w[DA003 A], %w[DA005 A], %w[SE003 A], %w[SE014 A]] }

      let(:expected_result) do
        {
          dependant_allowance: 220.21,
          gross_housing_costs: 990.42,
          housing_benefit: 440.21,
          net_housing_costs: 550.21,
          maintenance_allowance: 330.21,
          total_outgoings_and_allowances: 660.21,
          total_disposable_income: 732.55,
          employment_income:
            {
              benefits_in_kind: 0.0,
              fixed_employment_deduction: -45.0,
              gross_income: 0.0,
              national_insurance: 0.0,
              net_employment_income: -45.0,
              tax: 0.0,
            },
          income_contribution: 75.0,
          proceeding_types: [
            {
              ccms_code: "DA003",
              client_involvement_type: "A",
              lower_threshold: 315.0,
              upper_threshold: 999_999_999_999.0,
              result: "contribution_required",
            },
            {
              ccms_code: "DA005",
              client_involvement_type: "A",
              lower_threshold: 315.0,
              upper_threshold: 999_999_999_999.0,
              result: "contribution_required",
            },
            {
              ccms_code: "SE003",
              client_involvement_type: "A",
              lower_threshold: 315.0,
              upper_threshold: 733.0,
              result: "ineligible",
            },
            {
              ccms_code: "SE014",
              client_involvement_type: "A",
              lower_threshold: 315.0,
              upper_threshold: 733.0,
              result: "ineligible",
            },
          ],
        }
      end

      subject(:decorator) { described_class.new(assessment).as_json }

      before do
        pt_results.each do |ptc, details|
          lower_threshold, upper_threshold, result = details

          create :disposable_income_eligibility,
                 disposable_income_summary: summary,
                 proceeding_type_code: ptc,
                 upper_threshold:,
                 lower_threshold:,
                 assessment_result: result
        end
      end

      describe "#as_json" do
        it "returns the expected structure" do
          employment1
          employment2
          Calculators::EmploymentIncomeCalculator.call(assessment)
          expect(decorator).to eq expected_result
        end
      end
    end
  end
end
