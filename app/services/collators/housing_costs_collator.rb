module Collators
  class HousingCostsCollator < BaseWorkflowService
    def call
      housing_calculator = Calculators::HousingCostsCalculator.new(assessment)
      monthly_housing_benefit = disposable_income_summary.calculate_monthly_equivalent(collection: housing_benefit_records)
      disposable_income_summary.update!(
        housing_benefit: monthly_housing_benefit,
        gross_housing_costs: housing_calculator.monthly_actual_housing_costs,
        net_housing_costs: housing_calculator.net_housing_costs
      )
    end

    private

    def housing_benefit_records
      gross_income_summary.housing_benefit_payments
    end
  end
end
