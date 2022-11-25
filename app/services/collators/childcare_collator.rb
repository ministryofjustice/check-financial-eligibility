module Collators
  class ChildcareCollator
    include Transactions

    class << self
      def call(disposable_income_summary:, gross_income_summary:, eligible_for_childcare:)
        new(disposable_income_summary:, gross_income_summary:, eligible_for_childcare:).call
      end
    end

    def initialize(disposable_income_summary:, gross_income_summary:, eligible_for_childcare:)
      @disposable_income_summary = disposable_income_summary
      @gross_income_summary = gross_income_summary
      @eligible_for_childcare = eligible_for_childcare
    end

    def call
      @disposable_income_summary.calculate_monthly_childcare_amount!(@eligible_for_childcare, monthly_child_care_cash)
    end

  private

    def monthly_child_care_cash
      monthly_cash_transaction_amount_by(gross_income_summary: @gross_income_summary, operation: :debit, category: :child_care)
    end
  end
end
