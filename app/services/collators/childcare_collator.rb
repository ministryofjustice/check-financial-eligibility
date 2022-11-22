module Collators
  class ChildcareCollator < BaseWorkflowService
    include Transactions
    include ChildcareEligibility

    def call
      disposable_income_summary.calculate_monthly_childcare_amount!(eligible_for_childcare_costs?, monthly_child_care_cash)
    end

  private

    def monthly_child_care_cash
      monthly_cash_transaction_amount_by(operation: :debit, category: :child_care)
    end
  end
end
