module Decorators
  module V5
    class CapitalResultDecorator
      def initialize(assessment)
        @assessment = assessment
      end

      def as_json
        {
          total_liquid: summary.total_liquid.to_f,
          total_non_liquid: summary.total_non_liquid.to_f,
          total_vehicle: summary.total_vehicle.to_f,
          total_property: summary.total_property.to_f,
          total_mortgage_allowance: summary.total_mortgage_allowance.to_f,
          total_capital: summary.total_capital.to_f,
          pensioner_capital_disregard: summary.pensioner_capital_disregard.to_f,
          subject_matter_of_dispute_disregard: summary.subject_matter_of_dispute_disregard.to_f,
          capital_contribution: summary.capital_contribution.to_f,
          assessed_capital: summary.assessed_capital.to_f,
          proceeding_types: ProceedingTypesResultDecorator.new(summary).as_json,
        }
      end

    private

      def summary
        @summary ||= @assessment.capital_summary
      end
    end
  end
end
