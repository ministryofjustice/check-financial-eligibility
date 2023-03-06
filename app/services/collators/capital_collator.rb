module Collators
  class CapitalCollator
    class << self
      def call(submission_date:, capital_summary:, pensioner_capital_disregard:, maximum_subject_matter_of_dispute_disregard:, level_of_help:)
        new(submission_date:, capital_summary:, pensioner_capital_disregard:, maximum_subject_matter_of_dispute_disregard:, level_of_help:).call
      end
    end

    def initialize(submission_date:, capital_summary:, pensioner_capital_disregard:, maximum_subject_matter_of_dispute_disregard:, level_of_help:)
      @submission_date = submission_date
      @capital_summary = capital_summary
      @pensioner_capital_disregard = pensioner_capital_disregard
      @maximum_subject_matter_of_dispute_disregard = maximum_subject_matter_of_dispute_disregard
      @level_of_help = level_of_help
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
                                                        level_of_help: @level_of_help)
      property_value = properties.sum(&:assessed_equity)
      property_smod = properties.sum(&:smod_allowance)
      vehicles = Assessors::VehicleAssessor.call(@capital_summary.vehicles, @submission_date)
      vehicle_value = vehicles.sum(&:value)
      subject_matter_of_dispute_disregard = Calculators::SubjectMatterOfDisputeDisregardCalculator.new(
        capital_summary: @capital_summary,
        maximum_disregard: @maximum_subject_matter_of_dispute_disregard - property_smod,
      ).value
      total_capital = liquid_capital + non_liquid_capital + vehicle_value + property_value
      total_capital_with_smod = total_capital - subject_matter_of_dispute_disregard
      assessed_capital = total_capital_with_smod - @pensioner_capital_disregard

      PersonCapitalSubtotals.new(
        total_liquid: liquid_capital,
        total_non_liquid: non_liquid_capital,
        total_vehicle: vehicle_value,
        total_mortgage_allowance: property_maximum_mortgage_allowance_threshold,
        total_property: property_value,
        pensioner_capital_disregard: @pensioner_capital_disregard,
        pensioner_disregard_applied: [@pensioner_capital_disregard, total_capital].min,
        subject_matter_of_dispute_disregard: subject_matter_of_dispute_disregard + property_smod,
        total_capital:,
        total_capital_with_smod:,
        assessed_capital: [assessed_capital, 0].max,
        main_home: @capital_summary.main_home.present? ? PropertySubtotals.new(properties.detect(&:main_home)) : PropertySubtotals.new,
        additional_properties: properties.reject(&:main_home).map { |p| PropertySubtotals.new(p) },
      )
    end

    def property_maximum_mortgage_allowance_threshold
      Threshold.value_for(:property_maximum_mortgage_allowance, at: @submission_date)
    end
  end
end
