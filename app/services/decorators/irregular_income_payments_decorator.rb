module Decorators
  class IrregularIncomePaymentsDecorator
    def initialize(record)
      @record = Array(record)
    end

    def as_json
      {
        payments: payments
      }
    end

    private

    def payments
      return [] if @record.blank?

      @record.map do |payment|
        {
          income_type: payment.income_type,
          frequency: payment.frequency,
          amount: payment.amount
        }
      end
    end
  end
end
