module Decorators
  module V5
    class GrossIncomeResultDecorator
      delegate :gross_income_summary, to: :assessment

      attr_reader :assessment

      def initialize(assessment)
        @assessment = assessment
      end

      def as_json
        {
          total_gross_income: gross_income_summary.total_gross_income.to_f,
          proceeding_types: ProceedingTypesResultDecorator.new(summary).as_json,
        }
      end

    private

      def summary
        @summary ||= @assessment.gross_income_summary
      end
    end
  end
end
