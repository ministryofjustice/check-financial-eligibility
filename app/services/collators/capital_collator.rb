module Collators
  class CapitalCollator
    RETURN_VALUES = {
      total_liquid: "liquid_capital",
      total_non_liquid: "non_liquid_capital",
      total_vehicle: "vehicles",
      total_mortgage_allowance: "property_maximum_mortgage_allowance_threshold",
      total_property: "property",
      pensioner_capital_disregard: "pensioner_capital_disregard",
      subject_matter_of_dispute_disregard: "subject_matter_of_dispute_disregard",
      total_capital: "total_capital",
      assessed_capital: "assessed_capital",
      capital_contribution: "capital_contribution",
    }.freeze

    class << self
      def call(submission_date:, capital_summary:, pensioner_capital_disregard:, maximum_subject_matter_of_dispute_disregard:)
        new(submission_date:, capital_summary:, pensioner_capital_disregard:, maximum_subject_matter_of_dispute_disregard:).call
      end
    end

    def initialize(submission_date:, capital_summary:, pensioner_capital_disregard:, maximum_subject_matter_of_dispute_disregard:)
      @submission_date = submission_date
      @capital_summary = capital_summary
      @pensioner_capital_disregard = pensioner_capital_disregard
      @maximum_subject_matter_of_dispute_disregard = maximum_subject_matter_of_dispute_disregard
    end

    def call
      RETURN_VALUES.deep_transform_values { |value| send(value) }
    end

  private

    attr_reader :pensioner_capital_disregard

    def assessed_capital
      total_capital - pensioner_capital_disregard - subject_matter_of_dispute_disregard
    end

    def subject_matter_of_dispute_disregard
      Calculators::SubjectMatterOfDisputeDisregardCalculator.new(capital_summary: @capital_summary,
                                                                 maximum_disregard: @maximum_subject_matter_of_dispute_disregard).value
    end

    def total_capital
      @total_capital ||= liquid_capital + non_liquid_capital + vehicles + property
    end

    def liquid_capital
      @liquid_capital ||= Assessors::LiquidCapitalAssessor.call(@capital_summary)
    end

    def non_liquid_capital
      @non_liquid_capital ||= Assessors::NonLiquidCapitalAssessor.call(@capital_summary)
    end

    def property
      @property ||= Calculators::PropertyCalculator.call(submission_date: @submission_date,
                                                         capital_summary: @capital_summary)
    end

    def vehicles
      @vehicles ||= Assessors::VehicleAssessor.call(@capital_summary.vehicles)
    end

    def property_maximum_mortgage_allowance_threshold
      Threshold.value_for(:property_maximum_mortgage_allowance, at: @submission_date)
    end

    def lower_threshold
      Threshold.value_for(:capital_lower, at: @submission_date)
    end

    def capital_contribution
      [0, assessed_capital - lower_threshold].max
    end
  end
end
