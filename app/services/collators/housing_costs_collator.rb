module Collators
  class HousingCostsCollator < BaseWorkflowService
    def call
      housing_calculator = Calculators::HousingCostsCalculator.new(assessment)
      disposable_income_summary.update!(
        housing_benefit: housing_calculator.monthly_housing_benefit,
        gross_housing_costs: housing_calculator.gross_housing_costs,
        net_housing_costs: housing_calculator.net_housing_costs
      )
    end
  end
end
