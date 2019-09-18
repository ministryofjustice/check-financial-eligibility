module WorkflowService
  class PensionerCapitalDisregard < BaseWorkflowService
    def value
      return 0 unless pensioner?

      return passported_value if passported?

      raise 'Not implemented: PensionerCapitalDisregard for unpassported applicants'
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
      WorkflowPredicate::DeterminePassported.call(assessment)
    end

    def passported_value
      thresholds[:passported]
    end
  end
end
