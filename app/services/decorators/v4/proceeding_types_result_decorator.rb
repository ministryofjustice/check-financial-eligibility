module Decorators
  module V4
    class ProceedingTypesResultDecorator
      def initialize(assessment)
        @assessment = assessment
      end

      def as_json
        @assessment.proceeding_type_codes.map { |ptc| ptc_result(ptc) }
      end

      private

      def ptc_result(ptc)
        elig = @assessment.eligibilities.find_by(proceeding_type_code: ptc)
        {
          ccms_code: ptc,
          result: elig.assessment_result
        }
      end
    end
  end
end
