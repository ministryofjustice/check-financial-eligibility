module Collators
  class ChildcareCollator < BaseWorkflowService
    include Transactions

    def call
      disposable_income_summary.calculate_monthly_childcare_amount!(eligible_for_childcare_costs?, monthly_child_care_cash)
    end

  private

    def eligible_for_childcare_costs?
      applicant_has_dependent_child? && (applicant_employed? || applicant_has_student_loan?)
    end

    def monthly_child_care_cash
      monthly_cash_transaction_amount_by(operation: :debit, category: :child_care)
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
      student_loan_payments.any?
    end
  end
end
