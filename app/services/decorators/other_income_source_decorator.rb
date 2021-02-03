module Decorators
  class OtherIncomeSourceDecorator
    include Transactions

    attr_reader :record, :categories

    def initialize(record)
      @record = record
      @categories = CFEConstants::VALID_INCOME_CATEGORIES.map(&:to_sym)
    end

    def as_json
      record.v3? ? payload_v3 : payload_v2
    end

    private

    def payload_v2
      {
        name: record.name,
        monthly_income: record.monthly_income,
        payments: payments
      }
    end

    def payload_v3
      {
        monthly_equivalents: all_transaction_types
      }
    end

    def payments
      record.other_income_payments.map do |payment|
        PaymentDecorator.new(payment).as_json
      end
    end
  end
end
