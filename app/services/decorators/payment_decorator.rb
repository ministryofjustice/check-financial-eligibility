module Decorators
  class PaymentDecorator
    def initialize(record)
      @record = record
    end

    def as_json
      {
        payment_date: @record.payment_date,
        amount: @record.amount
      }
    end
  end
end
