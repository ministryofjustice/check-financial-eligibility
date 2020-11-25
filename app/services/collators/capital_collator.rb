module Collators
  class CapitalCollator < BaseWorkflowService
    PREPEND_VALUES = {
      total_liquid: 'liquid_capital',
      total_non_liquid: 'non_liquid_capital',
      total_vehicle: 'vehicles'
    }.freeze

    APPEND_VALUES = {
      total_property: 'property',
      pensioner_capital_disregard: 'pensioner_capital_disregard',
      total_capital: 'total_capital',
      assessed_capital: 'assessed_capital',
      lower_threshold: 'lower_threshold',
      upper_threshold: 'upper_threshold',
      capital_contribution: 'capital_contribution'
    }.freeze

    def call
      # TODO: refactor this because total mortgage allowance will be removed on or after 8/1/2021
      return_values = PREPEND_VALUES.merge(total_mortgage_allowance).merge(APPEND_VALUES)

      return_values.deep_transform_values do |value|
        send(value)
      end
    end

    private

    def total_mortgage_allowance
      if Time.current.before?(Time.zone.parse('2021-01-08'))
        { total_mortgage_allowance: 'property_maximum_mortgage_allowance_threshold' }
      else
        {}
      end
    end

    def assessed_capital
      total_capital - pensioner_capital_disregard
    end

    def total_capital
      @total_capital ||= liquid_capital + non_liquid_capital + vehicles + property
    end

    def liquid_capital
      @liquid_capital ||= Assessors::LiquidCapitalAssessor.call(assessment)
    end

    def non_liquid_capital
      @non_liquid_capital ||= Assessors::NonLiquidCapitalAssessor.call(assessment)
    end

    def property
      @property ||= Calculators::PropertyCalculator.call(assessment)
    end

    def vehicles
      @vehicles ||= Assessors::VehicleAssessor.call(assessment)
    end

    def property_maximum_mortgage_allowance_threshold
      Threshold.value_for(:property_maximum_mortgage_allowance, at: submission_date)
    end

    def pensioner_capital_disregard
      @pensioner_capital_disregard ||= Calculators::PensionerCapitalDisregardCalculator.new(assessment).value
    end

    def lower_threshold
      Threshold.value_for(:capital_lower, at: assessment.submission_date)
    end

    def upper_threshold
      return infinite_threshold if assessment.matter_proceeding_type == 'domestic_abuse' && assessment.applicant.involvement_type == 'applicant'

      Threshold.value_for(:capital_upper, at: assessment.submission_date)
    end

    def capital_contribution
      [0, assessed_capital - lower_threshold].max
    end

    def infinite_threshold
      @infinite_threshold ||= Threshold.value_for(:infinite_gross_income_upper, at: assessment.submission_date)
    end
  end
end
