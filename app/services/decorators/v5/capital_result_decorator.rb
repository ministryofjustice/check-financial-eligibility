module Decorators
  module V5
    class CapitalResultDecorator
      def initialize(summary, person_capital_subtotals, capital_contribution, combined_assessed_capital)
        @summary = summary
        @person_capital_subtotals = person_capital_subtotals
        @capital_contribution = capital_contribution
        @combined_assessed_capital = combined_assessed_capital
      end

      def as_json
        if @summary.is_a?(ApplicantCapitalSummary)
          basic_attributes.merge(proceeding_types:,
                                 pensioner_disregard_applied: @person_capital_subtotals.pensioner_disregard_applied.to_f,
                                 combined_assessed_capital:,
                                 combined_capital_contribution:)
        else
          basic_attributes
        end
      end

      def basic_attributes
        {
          total_liquid: @person_capital_subtotals.total_liquid.to_f,
          total_non_liquid: @person_capital_subtotals.total_non_liquid.to_f,
          total_vehicle: @person_capital_subtotals.total_vehicle.to_f,
          total_property: @person_capital_subtotals.total_property.to_f,
          total_mortgage_allowance: @person_capital_subtotals.total_mortgage_allowance.to_f,
          total_capital: @person_capital_subtotals.total_capital.to_f,
          pensioner_capital_disregard: @person_capital_subtotals.pensioner_capital_disregard.to_f,
          subject_matter_of_dispute_disregard: @person_capital_subtotals.subject_matter_of_dispute_disregard.to_f,
          capital_contribution: @capital_contribution,
          assessed_capital: @person_capital_subtotals.assessed_capital.to_f,
        }
      end

    private

      def proceeding_types
        ProceedingTypesResultDecorator.new(@summary).as_json
      end

      def combined_assessed_capital
        @combined_assessed_capital.to_f
      end

      def combined_capital_contribution
        @capital_contribution
      end
    end
  end
end
