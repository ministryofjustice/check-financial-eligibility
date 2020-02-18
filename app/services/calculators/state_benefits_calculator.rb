module Calculators
  class StateBenefitsCalculator < BaseWorkflowService
    def call
      total_monthly_state_benefits
    end

    private

    def total_monthly_state_benefits
      total = 0.0
      state_benefits.each do |state_benefit|
        state_benefit.calculate_monthly_amount!
        total += state_benefit.monthly_value unless state_benefit.exclude_from_gross_income
      end
      total
    end
  end
end
