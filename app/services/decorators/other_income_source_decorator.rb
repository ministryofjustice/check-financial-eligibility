module Decorators
  class OtherIncomeSourceDecorator
    INCOME_CATEGORIES = CFEConstants::VALID_INCOME_CATEGORIES.map(&:to_sym)

    def initialize(record)
      @record = record
    end

    def as_json
      case @record.version
      when CFEConstants::LATEST_ASSESSMENT_VERSION
        payload_v3
      else
        payload_v2
      end
    end

    private

    def payload_v2
      {
        name: @record.name,
        monthly_income: @record.monthly_income,
        payments: payments
      }
    end

    def payload_v3
      {
        monthly_equivalents: {
          bank_transactions: income_transactions(transaction_type: :bank),
          cash_transactions: income_transactions(transaction_type: :cash),
          all_sources: income_transactions(transaction_type: :all_sources)
        }
      }
    end

    def income_transactions(transaction_type:)
      income_transactions = {}

      INCOME_CATEGORIES.each do |category|
        income_transactions[category] = @record["#{category}_#{transaction_type}"]
      end

      income_transactions
    end

    def payments
      @record.other_income_payments.map do |payment|
        PaymentDecorator.new(payment).as_json
      end
    end
  end
end
