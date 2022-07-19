module Decorators
  module V5
    class DisposableIncomeResultDecorator
      def initialize(assessment)
        @assessment = assessment
      end

      def as_json
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
          proceeding_types: ProceedingTypesResultDecorator.new(summary).as_json,
        }
      end

    private

      def summary
        @summary ||= @assessment.disposable_income_summary
      end

      def gross_income_summary
        @gross_income_summary ||= @assessment.gross_income_summary
      end

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
    end
  end
end
