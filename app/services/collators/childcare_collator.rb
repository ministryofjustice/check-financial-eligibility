module Collators
  class ChildcareCollator < BaseWorkflowService
    def call
      return unless eligible_for_childcare_costs?

      collate!
    end

    private

    def eligible_for_childcare_costs?
      applicant_has_dependent_child? && (applicant_employed? || applicant_has_student_loan?)
    end

    def applicant_has_dependent_child?
      assessment.dependants.each do |dependant|
        return true if dependant.date_of_birth > assessment.submission_date - 15.years
      end
      false
    end

    def applicant_employed?
      # for now, no applicants are employed, but when they are, we will want to test this
      # by checking for earned income
      false
    end

    def applicant_has_student_loan?
      return true if irregular_income_payments&.present?

      false
    end

    def collate!
      disposable_income_summary.calculate_monthly_childcare_amount!
    end
  end
end
