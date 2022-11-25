module Decorators
  module V5
    class GrossIncomeResultDecorator
      def initialize(summary)
        @summary = summary
      end

      def as_json
        if @summary.is_a?(ApplicantGrossIncomeSummary)
          basic_attributes.merge(proceeding_types:, combined_total_gross_income:)
        else
          basic_attributes
        end
      end

      def basic_attributes
        {
          total_gross_income: summary.total_gross_income.to_f,
        }
      end

    private

      attr_reader :summary

      def proceeding_types
        ProceedingTypesResultDecorator.new(summary).as_json
      end

      def combined_total_gross_income
        summary.combined_total_gross_income.to_f
      end
    end
  end
end
