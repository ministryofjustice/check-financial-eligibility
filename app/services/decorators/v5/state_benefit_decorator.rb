module Decorators
  module V5
    class StateBenefitDecorator
      def initialize(state_benefit)
        @state_benefit = state_benefit
      end

      def as_json
        {
          name: @state_benefit.state_benefit_name,
          monthly_value: @state_benefit.monthly_value.to_f,
          excluded_from_income_assessment: @state_benefit.exclude_from_gross_income
        }
      end
    end
  end
end
