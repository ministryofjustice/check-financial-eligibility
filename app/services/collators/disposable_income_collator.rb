module Collators
  class DisposableIncomeCollator < BaseWorkflowService
    include Transactions

    attr_accessor :monthly_cash_transactions_total

    OUTGOING_CATEGORIES = CFEConstants::VALID_OUTGOING_CATEGORIES.map(&:to_sym)

    delegate :net_housing_costs,
             :rent_or_mortgage_bank,
             :child_care_bank,
             :maintenance_out_bank,
             :dependant_allowance,
             :legal_aid_bank, to: :disposable_income_summary

    delegate :total_gross_income, to: :gross_income_summary

    def initialize(assessment)
      super(assessment)
      @monthly_cash_transactions_total = 0
    end

    def call
      attrs = {}
      populate_attrs_v3 attrs if assessment.v3?

      attrs = attrs.merge(default_attrs)

      disposable_income_summary.update!(attrs)
    end

    private

    def populate_attrs_v3(attrs)
      OUTGOING_CATEGORIES.each do |category|
        monthly_cash_amount = monthly_transaction_amount_by(operation: :debit, category: category)
        @monthly_cash_transactions_total += monthly_cash_amount

        attrs[:"#{category}_bank"] = __send__("#{category}_bank")
        attrs[:"#{category}_cash"] = monthly_cash_amount
        attrs[:"#{category}_all_sources"] = attrs[:"#{category}_bank"] + attrs[:"#{category}_cash"]
      end
    end

    def default_attrs
      {
        total_outgoings_and_allowances: total_outgoings_and_allowances,
        total_disposable_income: disposable_income,
        lower_threshold: lower_threshold,
        upper_threshold: upper_threshold
      }
    end

    def total_outgoings_and_allowances
      net_housing_costs + dependant_allowance + child_care_bank + maintenance_out_bank + legal_aid_bank + @monthly_cash_transactions_total
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
