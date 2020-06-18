module Collators
  class ChildcareCollator < BaseWorkflowService
    def call
      return unless applicant_has_dependent_child?

      collate! if applicant_employed? || applicant_has_student_loan?
    end

    private

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

    # TODO: remove using other income sources for student learn and instead use irregular_income_payments
    # once other income sources no longer stores student_loan
    def applicant_has_student_loan?
      other_income_sources.each do |source|
        return true if source.student_payment?
      end
      return true if irregular_income_payments&.present?

      false
    end

    def collate!
      disposable_income_summary.calculate_monthly_childcare_amount!
    end
  end
end
