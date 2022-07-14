module Decorators
  module V4
    class AdjustedIncomeResultDecorator
      delegate :gross_income_summary, to: :assessment

      attr_reader :assessment

      def initialize(assessment)
        @assessment = assessment
      end

      def as_json
        {
          adjusted_income: gross_income_summary.adjusted_income.to_f.round(2),
          lower_threshold: gross_income_summary.crime_eligibility.lower_threshold.to_f,
          upper_threshold: gross_income_summary.crime_eligibility.upper_threshold.to_f,
          result: gross_income_summary.crime_eligibility.assessment_result,
        }
      end
    end
  end
end
