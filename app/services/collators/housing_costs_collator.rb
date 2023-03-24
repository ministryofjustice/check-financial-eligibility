module Collators
  class HousingCostsCollator
    Result = Data.define(:housing_benefit, :gross_housing_costs, :gross_housing_costs_bank, :net_housing_costs)

    class << self
      def call(disposable_income_summary:, gross_income_summary:, submission_date:, person:, allow_negative_net:)
        housing_calculator = Calculators::HousingCostsCalculator.new(disposable_income_summary:, gross_income_summary:,
                                                                     submission_date:, person:)

        net_housing_costs = if allow_negative_net
                              housing_calculator.net_housing_costs
                            else
                              [housing_calculator.net_housing_costs, 0.0].max
                            end

        Result.new(
          housing_benefit: housing_calculator.monthly_housing_benefit,
          gross_housing_costs: housing_calculator.gross_housing_costs,
          gross_housing_costs_bank: housing_calculator.gross_housing_costs_bank,
          net_housing_costs:,
        )
      end
    end
  end
end
