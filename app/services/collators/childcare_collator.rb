module Collators
  class ChildcareCollator
    include Transactions
    include ChildcareEligibility

    class << self
      def call(submission_date:, disposable_income_summary:, gross_income_summary:, person:)
        new(submission_date:, disposable_income_summary:, gross_income_summary:, person:).call
      end
    end

    def initialize(submission_date:, disposable_income_summary:, gross_income_summary:, person:)
      @submission_date = submission_date
      @disposable_income_summary = disposable_income_summary
      @gross_income_summary = gross_income_summary
      @person = person
    end

    def call
      @disposable_income_summary.calculate_monthly_childcare_amount!(eligible_for_childcare_costs?(@person, @submission_date),
                                                                     monthly_child_care_cash)
    end

  private

    def monthly_child_care_cash
      monthly_cash_transaction_amount_by(gross_income_summary: @gross_income_summary, operation: :debit, category: :child_care)
    end
  end
end
