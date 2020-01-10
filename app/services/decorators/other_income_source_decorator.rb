module Decorators
  class OtherIncomeSourceDecorator
    def initialize(record)
      @record = record
    end

    def as_json
      {
        name: @record.name,
        monthly_income: @record.monthly_income,
        payments: payments
      }
    end

    private

    def payments
      @record.other_income_payments.map do |payment|
        PaymentDecorator.new(payment).as_json
      end
    end
  end
end
