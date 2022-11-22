module Collators
  class HousingCostsCollator
    class << self
      def call(disposable_income_summary:, gross_income_summary:, submission_date:, person:)
        housing_calculator = Calculators::HousingCostsCalculator.new(disposable_income_summary:, gross_income_summary:,
                                                                     submission_date:, person:)

        disposable_income_summary.update!(
          housing_benefit: housing_calculator.monthly_housing_benefit,
          gross_housing_costs: housing_calculator.gross_housing_costs,
          net_housing_costs: housing_calculator.net_housing_costs,
        )
      end
  end
  end
end
