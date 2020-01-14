module Decorators
  class StateBenefitDecorator
    def initialize(state_benefit)
      @state_benefit = state_benefit
    end

    def as_json
      {
        name: @state_benefit.state_benefit_name,
        monthly_value: @state_benefit.monthly_value,
        excluded_from_income_assessment: @state_benefit.exclude_from_gross_income,
        state_benefit_payments: payments
      }
    end

    private

    def payments
      @state_benefit.state_benefit_payments.map do |payment|
        PaymentDecorator.new(payment).as_json
      end
    end
  end
end
