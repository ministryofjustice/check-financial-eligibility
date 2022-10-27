module Collators
  class ChildcareCollator < BaseWorkflowService
    include Transactions

    def call
      disposable_income_summary.calculate_monthly_childcare_amount!(eligible_for_childcare_costs?, monthly_child_care_cash)
    end

  private

    def eligible_for_childcare_costs?
      applicant_has_dependant_child? && (applicant_is_employed? || applicant_has_student_loan?)
    end

    def monthly_child_care_cash
      monthly_cash_transaction_amount_by(operation: :debit, category: :child_care)
    end

    def applicant_has_dependant_child?
      assessment.dependants.any? do |dependant|
        assessment.submission_date.before?(dependant.becomes_adult_on)
      end
    end

    def applicant_is_employed?
      !!applicant&.employed?
    end

    def applicant_has_student_loan?
      student_loan_payments.any?
    end
  end
end
