module Calculators
  class HousingCostsCalculator < BaseWorkflowService
    delegate :disposable_income_summary, to: :assessment
    delegate :housing_cost_outgoings, to: :disposable_income_summary
    delegate :submission_date, :dependants, to: :assessment
    delegate :applicant, to: :assessment

    def call
      monthly_actual_housing_costs = disposable_income_summary.calculate_monthly_equivalent(collection: housing_cost_outgoings, amount_method: :allowable_amount)
      housing_costs_cap_apply? ? [monthly_actual_housing_costs, single_monthly_housing_costs_cap].min : monthly_actual_housing_costs
    end

    private

    def single_monthly_housing_costs_cap
      Threshold.value_for(:single_monthly_housing_costs_cap, at: submission_date)
    end

    def housing_costs_cap_apply?
      applicant_single? && applicant_has_no_dependants?
    end

    def applicant_single?
      # assume true for MVP
      true
    end

    def applicant_has_no_dependants?
      dependants.size.zero?
    end
  end
end
