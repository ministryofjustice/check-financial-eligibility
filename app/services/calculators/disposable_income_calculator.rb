module Calculators
  class DisposableIncomeCalculator < BaseWorkflowService
    delegate :disposable_income_summary,
             :gross_income_summary, to: :assessment

    delegate :childcare,
             :dependant_allowance,
             :maintenance,
             :net_housing_costs, to: :disposable_income_summary

    delegate :total_gross_income, to: :gross_income_summary

    delegate :submission_date, to: :assessment

    def call
      disposable_income_summary.update!(total_disposable_income: total_disposable_income,
                                        lower_threshold: lower_threshold,
                                        upper_threshold: upper_threshold)
    end

    private

    def total_disposable_income
      [0, total_gross_income - total_expenses_and_allowances].max
    end

    def total_expenses_and_allowances
      childcare + dependant_allowance + maintenance + net_housing_costs
    end

    def upper_threshold
      Threshold.value_for(:disposable_income_upper, at: submission_date)
    end

    def lower_threshold
      Threshold.value_for(:disposable_income_lower, at: submission_date)
    end
  end
end
