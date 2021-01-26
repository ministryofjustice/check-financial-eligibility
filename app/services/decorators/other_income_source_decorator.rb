module Decorators
  class OtherIncomeSourceDecorator
    def initialize(record)
      @record = record
    end

    def as_json # rubocop:disable Metrics/MethodLength
      case @record.version
      when CFEConstants::LATEST_ASSESSMENT_VERSION
        {
          monthly_equivalents: {
            bank_transactions: find_by(transaction_type: :bank),
            cash_transactions: find_by(transaction_type: :cash),
            all_sources: find_by(transaction_type: :all_sources)
          }
        }
      else
        {
          name: @record.name,
          monthly_income: @record.monthly_income,
          payments: payments
        }
      end
    end

    private

    def find_by(transaction_type:)
      income_categories = CFEConstants::VALID_INCOME_CATEGORIES.map(&:to_sym)
      income_categories.reduce({}) { |hash, cat| hash.update(cat => @record["#{cat}_#{transaction_type}"]) }
    end

    def payments
      @record.other_income_payments.map do |payment|
        PaymentDecorator.new(payment).as_json
      end
    end
  end
end
