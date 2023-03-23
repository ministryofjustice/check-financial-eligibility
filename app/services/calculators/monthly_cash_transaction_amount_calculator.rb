module Calculators
  class MonthlyCashTransactionAmountCalculator
    def self.call(gross_income_summary:, operation:, category:)
      transactions = CashTransaction.by_operation_and_category(gross_income_summary, operation, category)
      return 0.0 if transactions.empty?

      transactions.average(:amount).round(2)
    end
  end
end
