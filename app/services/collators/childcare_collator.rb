module Collators
  class ChildcareCollator
    Result = Data.define(:cash, :bank)

    class << self
      def call(childcare_outgoings:, gross_income_summary:, eligible_for_childcare:, assessment_errors:)
        new(childcare_outgoings:, gross_income_summary:, eligible_for_childcare:, assessment_errors:).call
      end
    end

    def initialize(childcare_outgoings:, gross_income_summary:, eligible_for_childcare:, assessment_errors:)
      @childcare_outgoings = childcare_outgoings
      @gross_income_summary = gross_income_summary
      @eligible_for_childcare = eligible_for_childcare
      @assessment_errors = assessment_errors
    end

    def call
      # TODO: Return these values instead of persisting them
      if @eligible_for_childcare
        Result.new(bank: child_care_bank, cash: child_care_cash)
      else
        Result.new(bank: 0, cash: 0)
      end
    end

  private

    def child_care_bank
      Calculators::MonthlyEquivalentCalculator.call(
        assessment_errors: @assessment_errors,
        collection: @childcare_outgoings,
      )
    end

    def child_care_cash
      Calculators::MonthlyCashTransactionAmountCalculator.call(gross_income_summary: @gross_income_summary, operation: :debit, category: :child_care)
    end
  end
end
