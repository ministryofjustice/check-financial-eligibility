module Decorators
  class StateBenefitDecorator
    attr_reader :record, :state_benefit

    def initialize(record, state_benefit)
      @record = record
      @state_benefit = state_benefit
    end

    def as_json
      {
        name: state_benefit.state_benefit_name,
        monthly_value: state_benefit.monthly_value,
        excluded_from_income_assessment: state_benefit.exclude_from_gross_income
      }
    end
  end
end
