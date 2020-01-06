module Calculators
  class DependantAllowanceCalculator
    def self.call(dependant)
      new(dependant).call
    end

    def initialize(dependant)
      @dependant = dependant
    end

    def call
      return child_under_15_allowance if under_15_years_old?

      return child_under_16_allowance if under_16_years_old?

      return under_18_in_full_time_education_allowance if under_18_in_full_time_education?

      return 0.0 if capital_over_allowance?

      positive_or_zero(adult_allowance - monthly_income)
    end

    def positive_or_zero(value)
      [0, value].max
    end

    def child_under_16_allowance
      positive_or_zero(child_aged_15_allowance - monthly_income)
    end

    def under_18_in_full_time_education_allowance
      positive_or_zero(child_16_and_over_allowance - monthly_income)
    end

    def under_15_years_old?
      @dependant.date_of_birth > (submission_date - 15.years)
    end

    def under_16_years_old?
      @dependant.date_of_birth > (submission_date - 16.years)
    end

    def monthly_income
      @dependant.monthly_income
    end

    def under_18_in_full_time_education?
      @dependant.date_of_birth > (submission_date - 18.years) && @dependant.in_full_time_education?
    end

    def submission_date
      @submission_date ||= assessment.submission_date
    end

    def assessment
      @assessment ||= @dependant.assessment
    end

    def capital_over_allowance?
      @dependant.assets_value > adult_dependant_allowance_capital_threshold
    end

    def child_under_15_allowance
      Threshold.value_for(:dependant_allowances, at: submission_date)[:child_under_15]
    end

    def child_aged_15_allowance
      Threshold.value_for(:dependant_allowances, at: submission_date)[:child_aged_15]
    end

    def child_16_and_over_allowance
      Threshold.value_for(:dependant_allowances, at: submission_date)[:child_16_and_over]
    end

    def adult_allowance
      Threshold.value_for(:dependant_allowances, at: submission_date)[:adult]
    end

    def adult_dependant_allowance_capital_threshold
      Threshold.value_for(:dependant_allowances, at: submission_date)[:adult_capital_threshold]
    end
  end
end
