module Decorators
  module V5
    class DisposableIncomeResultDecorator
      def initialize(summary, gross_income_summary, partner_present:)
        @summary = summary
        @gross_income_summary = gross_income_summary
        @partner_present = partner_present
      end

      def as_json
        if summary.is_a?(ApplicantDisposableIncomeSummary)
          basic_attributes.merge(proceeding_types:,
                                 combined_total_disposable_income:,
                                 combined_total_outgoings_and_allowances:,
                                 partner_allowance:)
        else
          basic_attributes
        end
      end

      def basic_attributes
        {
          dependant_allowance: summary.dependant_allowance.to_f,
          gross_housing_costs: summary.gross_housing_costs.to_f,
          housing_benefit: summary.housing_benefit.to_f,
          net_housing_costs: summary.net_housing_costs.to_f,
          maintenance_allowance: summary.maintenance_out_all_sources.to_f,
          total_outgoings_and_allowances: summary.total_outgoings_and_allowances.to_f,
          total_disposable_income: summary.total_disposable_income.to_f,
          employment_income:,
          income_contribution: summary.income_contribution.to_f,
        }
      end

    private

      attr_reader :summary, :gross_income_summary

      def net_employment_income
        gross_income_summary.gross_employment_income + summary.employment_income_deductions + summary.fixed_employment_allowance
      end

      def employment_income
        {
          gross_income: gross_income_summary.gross_employment_income.to_f,
          benefits_in_kind: gross_income_summary.benefits_in_kind.to_f,
          tax: summary.tax.to_f,
          national_insurance: summary.national_insurance.to_f,
          fixed_employment_deduction: summary.fixed_employment_allowance.to_f,
          net_employment_income: net_employment_income.to_f,
        }
      end

      def proceeding_types
        ProceedingTypesResultDecorator.new(summary).as_json
      end

      def partner_allowance
        return 0 unless @partner_present

        Threshold.value_for(:partner_allowance, at: @summary.assessment.submission_date)
      end

      def combined_total_disposable_income
        summary.combined_total_disposable_income.to_f
      end

      def combined_total_outgoings_and_allowances
        summary.combined_total_outgoings_and_allowances.to_f
      end
    end
  end
end
