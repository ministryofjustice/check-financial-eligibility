module Decorators
  class StateBenefitDecorator
    attr_reader :record, :state_benefit

    def initialize(record, state_benefit)
      @record = record
      @state_benefit = state_benefit
    end

    def as_json
      record.v3? ? payload_v3 : payload_v2
    end

    private

    def payload_v2
      {
        name: state_benefit.state_benefit_name,
        monthly_value: state_benefit.monthly_value,
        excluded_from_income_assessment: state_benefit.exclude_from_gross_income,
        state_benefit_payments: payments
      }
    end

    def payload_v3
      {
        name: state_benefit.state_benefit_name,
        monthly_value: state_benefit.monthly_value,
        excluded_from_income_assessment: state_benefit.exclude_from_gross_income
      }
    end

    def payments
      state_benefit.state_benefit_payments.map do |payment|
        PaymentDecorator.new(payment).as_json
      end
    end
  end
end
