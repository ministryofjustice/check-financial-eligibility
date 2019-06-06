module WorkflowService
  class PensionerCapitalDisregard
    def initialize(particulars)
      @particulars = particulars
      @submission_date = @particulars.request.meta_data.submission_date
      @thresholds = Threshold.value_for(:pensioner_capital_disregard, at: @submission_date)
    end

    def value
      return 0 unless pensioner?

      return passported_value if passported?

      raise "No disposable income specified for non-passported applicant" if disposable_income.nil?

      disregard_value(disposable_income)
    end

    private

    def pensioner?
      earliest_dob_for_pensioner
      @submission_date - minimum_pensioner_age.years >= applicant_dob
    end

    def earliest_dob_for_pensioner
      @submission_date - minimum_pensioner_age.years
    end

    def minimum_pensioner_age
      @thresholds[:minimum_age_in_years]
    end

    def applicant_dob
      @particulars.request.applicant.date_of_birth
    end

    def passported?
      WorkflowPredicate::DeterminePassported.new(@particulars).call
    end

    def passported_value
      @thresholds[:passported]
    end

    def disposable_income
      @particulars.response.details.income.monthly_disposable_income
    end

    def disregard_value(income)
      income_vals = @thresholds[:monthly_income_values]
      threshold = income_vals.keys.select { |k| income >= k }.max
      income_vals[threshold]
    end


  end
end
