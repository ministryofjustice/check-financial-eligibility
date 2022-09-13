module Calculators
  class HousingCostsCalculator < BaseWorkflowService
    include Transactions
    include MonthlyEquivalentCalculatable

    delegate :disposable_income_summary, :submission_date, :dependants, :applicant, to: :assessment
    delegate :housing_cost_outgoings, to: :disposable_income_summary

    def net_housing_costs
      if housing_costs_cap_apply?
        [gross_housing_costs, gross_cost_minus_housing_benefit, single_monthly_housing_costs_cap].min.to_f
      elsif should_halve_full_cost_minus_benefits?
        (monthly_actual_housing_costs - monthly_housing_benefit) / 2
      elsif should_exclude_housing_benefit?
        gross_cost_minus_housing_benefit
      else
        gross_housing_costs
      end
    end

    def gross_housing_costs
      @gross_housing_costs ||= gross_housing_costs_bank + gross_housing_costs_regular_transactions + gross_housing_costs_cash
    end

    def monthly_housing_benefit
      @monthly_housing_benefit = disposable_income_summary.calculate_monthly_equivalent(collection: housing_benefit_records)
    end

  private

    def gross_housing_costs_cash
      monthly_cash_transaction_amount_by(operation: :debit, category: :rent_or_mortgage)
    end

    def gross_housing_costs_bank
      disposable_income_summary.calculate_monthly_rent_or_mortgage_amount!
      disposable_income_summary.rent_or_mortgage_bank
    end

    def gross_housing_costs_regular_transactions
      monthly_regular_transaction_amount_by(operation: :debit, category: :rent_or_mortgage)
    end

    def monthly_actual_housing_costs
      @monthly_actual_housing_costs ||= calculate_actual_housing_costs + gross_housing_costs_cash
    end

    def calculate_actual_housing_costs
      disposable_income_summary.calculate_monthly_equivalent(collection: housing_cost_outgoings)
    end

    def gross_cost_minus_housing_benefit
      gross_housing_costs - monthly_housing_benefit
    end

    def housing_benefit_records
      gross_income_summary&.housing_benefit_payments
    end

    def all_board_and_lodging?
      housing_cost_outgoings.map(&:housing_cost_type).all?("board_and_lodging")
    end

    def should_halve_full_cost_minus_benefits?
      should_exclude_housing_benefit? && all_board_and_lodging?
    end

    def should_exclude_housing_benefit?
      applicant_has_dependants? && receiving_benefits?
    end

    def receiving_benefits?
      gross_income_summary&.housing_benefit_payments.present?
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

    def applicant_has_dependants?
      dependants.present?
    end
  end
end
