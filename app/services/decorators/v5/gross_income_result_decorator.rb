module Decorators
  module V5
    class GrossIncomeResultDecorator
      def initialize(summary, person_gross_income_subtotals, combined_monthly_gross_income)
        @summary = summary
        @person_gross_income_subtotals = person_gross_income_subtotals
        @combined_monthly_gross_income = combined_monthly_gross_income
      end

      def as_json
        if @summary.is_a?(ApplicantGrossIncomeSummary)
          basic_attributes.merge(proceeding_types:, combined_total_gross_income: @combined_monthly_gross_income)
        else
          basic_attributes
        end
      end

      def basic_attributes
        {
          total_gross_income: @person_gross_income_subtotals.total_gross_income.to_f,
        }
      end

    private

      attr_reader :summary

      def proceeding_types
        ProceedingTypesResultDecorator.new(summary.eligibilities, summary.assessment.proceeding_types).as_json
      end
    end
  end
end
