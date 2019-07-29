module WorkflowService
  class PensionerCapitalDisregard < BaseWorkflowService
    def value
      return 0 unless pensioner?

      return passported_value if passported?

      raise 'No disposable income specified for non-passported applicant' if disposable_income.nil?

      disregard_value(disposable_income)
    end

    def thresholds
      @thresholds ||= Threshold.value_for(:pensioner_capital_disregard, at: @submission_date)
    end

    private

    def pensioner?
      earliest_dob_for_pensioner >= applicant_dob
    end

    def earliest_dob_for_pensioner
      @submission_date - minimum_pensioner_age.years
    end

    def minimum_pensioner_age
      thresholds[:minimum_age_in_years]
    end

    def applicant_dob
      applicant.date_of_birth
    end

    def passported?
      WorkflowPredicate::DeterminePassported.new(@assessment).call
    end

    def passported_value
      thresholds[:passported]
    end

    def disposable_income
      return nil if result.details['income'].nil?

      result.details['income']['monthly_disposable_income']
    end

    def disregard_value(income)
      income_vals = thresholds[:monthly_income_values]
      threshold = income_vals.keys.select { |k| income >= k }.max
      income_vals[threshold]
    end
  end
end
