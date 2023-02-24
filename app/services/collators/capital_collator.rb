module Collators
  class CapitalCollator
    class << self
      def call(submission_date:, capital_summary:, pensioner_capital_disregard:, maximum_subject_matter_of_dispute_disregard:, level_of_representation:)
        new(submission_date:, capital_summary:, pensioner_capital_disregard:, maximum_subject_matter_of_dispute_disregard:, level_of_representation:).call
      end
    end

    def initialize(submission_date:, capital_summary:, pensioner_capital_disregard:, maximum_subject_matter_of_dispute_disregard:, level_of_representation:)
      @submission_date = submission_date
      @capital_summary = capital_summary
      @pensioner_capital_disregard = pensioner_capital_disregard
      @maximum_subject_matter_of_dispute_disregard = maximum_subject_matter_of_dispute_disregard
      @level_of_representation = level_of_representation
    end

    def call
      perform_assessments
    end

  private

    def perform_assessments
      liquid_capital = Assessors::LiquidCapitalAssessor.call(@capital_summary)
      non_liquid_capital = Assessors::NonLiquidCapitalAssessor.call(@capital_summary)
      properties = Calculators::PropertyCalculator.call(submission_date: @submission_date,
                                                        properties: @capital_summary.properties,
                                                        smod_level: @maximum_subject_matter_of_dispute_disregard,
                                                        level_of_representation: @level_of_representation)
      property_value = properties.sum(&:assessed_equity)
      property_smod = properties.sum(&:smod_applied)
      vehicles = Assessors::VehicleAssessor.call(@capital_summary.vehicles, @submission_date)
      subject_matter_of_dispute_disregard = Calculators::SubjectMatterOfDisputeDisregardCalculator.new(
        capital_summary: @capital_summary,
        maximum_disregard: @maximum_subject_matter_of_dispute_disregard - property_smod,
      ).value
      total_capital = liquid_capital + non_liquid_capital + vehicles + property_value
      assessed_capital = total_capital - @pensioner_capital_disregard - subject_matter_of_dispute_disregard

      PersonCapitalSubtotals.new(
        total_liquid: liquid_capital,
        total_non_liquid: non_liquid_capital,
        total_vehicle: vehicles,
        total_mortgage_allowance: property_maximum_mortgage_allowance_threshold,
        total_property: property_value,
        pensioner_capital_disregard: @pensioner_capital_disregard,
        subject_matter_of_dispute_disregard: subject_matter_of_dispute_disregard + property_smod,
        total_capital:,
        assessed_capital:,
      )
    end

    def property_maximum_mortgage_allowance_threshold
      Threshold.value_for(:property_maximum_mortgage_allowance, at: @submission_date)
    end
  end
end
