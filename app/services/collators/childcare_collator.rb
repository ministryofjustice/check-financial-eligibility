module Collators
  class ChildcareCollator
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
      # TODO: Return these values instead of persisting them
      return unless @eligible_for_childcare

      @disposable_income_summary.update!(
        child_care_bank:,
        child_care_cash:,
      )
    end

  private

    def child_care_bank
      Calculators::MonthlyEquivalentCalculator.call(
        assessment_errors: @disposable_income_summary.assessment.assessment_errors,
        collection: @disposable_income_summary.childcare_outgoings,
      )
    end

    def child_care_cash
      Calculators::MonthlyCashTransactionAmountCalculator.call(gross_income_summary: @gross_income_summary, operation: :debit, category: :child_care)
    end
  end
end
