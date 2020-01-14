module Collators
  class HousingCostsCollator < BaseWorkflowService
    def call
      monthly_gross_housing_costs = Calculators::HousingCostsCalculator.call(assessment)
      monthly_housing_benefit = disposable_income_summary.calculate_monthly_equivalent(collection: housing_benefit_records)
      disposable_income_summary.update!(
        housing_benefit: monthly_housing_benefit,
        gross_housing_costs: monthly_gross_housing_costs,
        net_housing_costs: monthly_gross_housing_costs - monthly_housing_benefit
      )
    end

    private

    def housing_cost_records
      disposable_income_summary.housing_cost_outgoings
    end

    def housing_benefit_records
      gross_income_summary.housing_benefit_payments
    end
  end
end
