module Decorators
  module V4
    class GrossIncomeResultDecorator
      delegate :gross_income_summary, to: :assessment

      attr_reader :assessment

      def initialize(assessment)
        @assessment = assessment
      end

      def as_json
        {
          total_gross_income: gross_income_summary.total_gross_income.to_f,
          proceeding_types: @assessment.proceeding_type_codes.map { |ptc| ptc_results(ptc) },
        }
      end

    private

      def ptc_results(ptc)
        elig = gross_income_summary.eligibilities.find_by(proceeding_type_code: ptc)
        {
          ccms_code: ptc.to_s,
          upper_threshold: elig.upper_threshold.to_f,
          result: elig.assessment_result,
        }
      end
    end
  end
end
