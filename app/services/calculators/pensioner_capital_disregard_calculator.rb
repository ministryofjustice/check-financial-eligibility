module Calculators
  class PensionerCapitalDisregardCalculator < BaseWorkflowService
    delegate :applicant, to: :assessment

    def value
      return 0 unless pensioner?

      passported? ? passported_value : non_passported_value
    end

    def thresholds
      @thresholds ||= Threshold.value_for(:pensioner_capital_disregard, at: submission_date)
    end

    private

    def pensioner?
      earliest_dob_for_pensioner >= applicant_dob
    end

    def earliest_dob_for_pensioner
      submission_date - minimum_pensioner_age.years
    end

    def minimum_pensioner_age
      thresholds[:minimum_age_in_years]
    end

    def applicant_dob
      applicant.date_of_birth
    end

    def passported?
      applicant.receives_qualifying_benefit
    end

    def passported_value
      thresholds[:passported]
    end

    def non_passported_value
      thresholds[:non_passported]
    end
  end
end
