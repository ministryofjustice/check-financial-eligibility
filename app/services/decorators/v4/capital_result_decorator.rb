module Decorators
  module V4
    class CapitalResultDecorator
      def initialize(assessment)
        @assessment = assessment
      end

      def as_json # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        {
          total_liquid: summary.total_liquid.to_f,
          total_non_liquid: summary.total_non_liquid.to_f,
          total_vehicle: summary.total_vehicle.to_f,
          total_property: summary.total_property.to_f,
          total_mortgage_allowance: summary.total_mortgage_allowance.to_f,
          total_capital: summary.total_capital.to_f,
          pensioner_capital_disregard: summary.pensioner_capital_disregard.to_f,
          capital_contribution: summary.capital_contribution.to_f,
          assessed_capital: summary.assessed_capital.to_f,
          proceeding_types: proceeding_type_results
        }
      end

    private

      def summary
        @summary ||= @assessment.capital_summary
      end

      def proceeding_type_results
        @assessment.proceeding_type_codes.map { |ptc| proceeding_type_result(ptc) }
      end

      def proceeding_type_result(ptc)
        elig = summary.eligibilities.find_by(proceeding_type_code: ptc)
        {
          ccms_code: ptc.to_s,
          lower_threshold: elig.lower_threshold.to_f,
          upper_threshold: elig.upper_threshold.to_f,
          result: elig.assessment_result
        }
      end
    end
  end
end
