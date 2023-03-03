module Decorators
  module V5
    class ProceedingTypesResultDecorator
      def initialize(eligibilities, proceeding_types)
        @eligibilities = eligibilities
        @proceeding_types = proceeding_types
      end

      def as_json
        @proceeding_types.order(:ccms_code).map { |proceeding_type| pt_result(proceeding_type) }
      end

    private

      def pt_result(proceeding_type)
        elig = @eligibilities.find_by(proceeding_type_code: proceeding_type.ccms_code)
        {
          ccms_code: proceeding_type.ccms_code,
          client_involvement_type: proceeding_type.client_involvement_type,
          upper_threshold: elig.upper_threshold.to_f,
          lower_threshold: elig.lower_threshold.to_f,
          result: elig.assessment_result,
        }
      end
    end
  end
end
