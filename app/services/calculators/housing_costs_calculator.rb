module Calculators
  class HousingCostsCalculator < BaseWorkflowService
    delegate :disposable_income_summary, :submission_date, :dependants, :applicant, to: :assessment
    delegate :housing_cost_outgoings, to: :disposable_income_summary

    def net_housing_costs
      housing_costs_cap_apply? ? [monthly_actual_housing_costs, single_monthly_housing_costs_cap].min.to_f : monthly_actual_housing_costs
    end

    def monthly_actual_housing_costs
      @monthly_actual_housing_costs ||= disposable_income_summary.calculate_monthly_equivalent(collection: housing_cost_outgoings, amount_method: :allowable_amount)
    end

    def monthly_housing_benefit
      disposable_income_summary.calculate_monthly_equivalent(collection: housing_benefit_records)
    end

    private

    def housing_benefit_records
      gross_income_summary.housing_benefit_payments
    end

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
