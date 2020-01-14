module Collators
  class DisposableIncomeCollator < BaseWorkflowService
    delegate :net_housing_costs,
             :childcare,
             :maintenance,
             :dependant_allowance, to: :disposable_income_summary

    delegate :total_gross_income, to: :gross_income_summary

    def call
      disposable_income_summary.update!(
        total_outgoings_and_allowances: total_outgoings_and_allowances,
        total_disposable_income: disposable_income,
        lower_threshold: lower_threshold,
        upper_threshold: upper_threshold
      )
    end

    private

    def total_outgoings_and_allowances
      net_housing_costs + childcare + maintenance + dependant_allowance
    end

    def disposable_income
      [0, total_gross_income - total_outgoings_and_allowances].max
    end

    def lower_threshold
      Threshold.value_for(:disposable_income_lower, at: assessment.submission_date)
    end

    def upper_threshold
      assessment.matter_proceeding_type == 'domestic_abuse' ? no_upper_limit : standard_upper_limit
    end

    def standard_upper_limit
      Threshold.value_for(:disposable_income_upper, at: assessment.submission_date)
    end

    def no_upper_limit
      Threshold.value_for(:infinite_gross_income_upper)
    end
  end
end
