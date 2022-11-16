module Calculators
  class PensionerCapitalDisregardCalculator
    def initialize(submission_date:, person:, total_disposable_income:, receives_qualifying_benefit:)
      @submission_date = submission_date
      @person = person
      @total_disposable_income = total_disposable_income
      @receives_qualifying_benefit = receives_qualifying_benefit
    end

    def value
      return 0 unless pensioner?

      passported? ? passported_value : non_passported_value
    end

    def thresholds
      @thresholds ||= Threshold.value_for(:pensioner_capital_disregard, at: @submission_date)
    end

  private

    def pensioner?
      earliest_dob_for_pensioner >= person_dob
    end

    def earliest_dob_for_pensioner
      @submission_date - minimum_pensioner_age.years
    end

    def minimum_pensioner_age
      thresholds[:minimum_age_in_years]
    end

    def person_dob
      @person.date_of_birth
    end

    def passported?
      @receives_qualifying_benefit
    end

    def non_passported_value
      income = @total_disposable_income.to_f
      thresholds[:monthly_income_values].each { |value_bands, banding| return banding if income_threshold_applies(income, value_bands) }
    end

    def passported_value
      thresholds[:non_passported]
    end

    def income_threshold_applies(income, key_array)
      (key_array.count.eql?(1) && income >= key_array[0]) || (income >= key_array[0] && income <= key_array[1])
    end
  end
end
