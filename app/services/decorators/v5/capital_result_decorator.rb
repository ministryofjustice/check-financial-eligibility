module Decorators
  module V5
    class CapitalResultDecorator
      def initialize(summary)
        @summary = summary
      end

      def as_json
        if @summary.is_a?(ApplicantCapitalSummary)
          basic_attributes.merge(proceeding_types:, combined_assessed_capital:, combined_capital_contribution:)
        else
          basic_attributes
        end
      end

      def basic_attributes
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
        }
      end

    private

      attr_reader :summary

      def proceeding_types
        ProceedingTypesResultDecorator.new(summary).as_json
      end

      def combined_assessed_capital
        summary.combined_assessed_capital.to_f
      end

      def combined_capital_contribution
        summary.combined_capital_contribution.to_f
      end
    end
  end
end
