module Collators
  class DisposableIncomeCollator < BaseWorkflowService
    include Transactions

    attr_accessor :monthly_cash_transactions_total

    OUTGOING_CATEGORIES = CFEConstants::VALID_OUTGOING_CATEGORIES.map(&:to_sym)

    delegate :net_housing_costs,
             :rent_or_mortgage_bank,
             :rent_or_mortgage_cash,
             :child_care_bank,
             :child_care_cash,
             :maintenance_out_bank,
             :maintenance_out_cash,
             :dependant_allowance,
             :legal_aid_bank,
             :legal_aid_cash, to: :disposable_income_summary

    delegate :total_gross_income,
             :gross_employment_income, to: :gross_income_summary

    def initialize(assessment)
      super(assessment)
      @monthly_cash_transactions_total = 0
    end

    def call
      disposable_income_summary.update!(populate_attrs)
    end

  private

    def populate_attrs
      attrs = {}

      OUTGOING_CATEGORIES.each do |category|
        monthly_cash_amount = category == :child_care ? __send__("#{category}_cash") : monthly_cash_by_category(category)
        @monthly_cash_transactions_total += monthly_cash_amount unless category == :rent_or_mortgage

        attrs[:"#{category}_bank"] = __send__("#{category}_bank")
        attrs[:"#{category}_cash"] = monthly_cash_amount
        attrs[:"#{category}_all_sources"] = attrs[:"#{category}_bank"] + attrs[:"#{category}_cash"]
      end

      attrs.merge(default_attrs)
    end

    def monthly_cash_by_category(category)
      monthly_transaction_amount_by(operation: :debit, category:)
    end

    def default_attrs
      {
        total_outgoings_and_allowances: total_outgoings_and_allowances,
        total_disposable_income: disposable_income,
      }
    end

    def fixed_employment_allowance
      @fixed_employment_allowance ||= disposable_income_summary.fixed_employment_allowance
    end

    def employment_income_deductions
      @employment_income_deductions ||= disposable_income_summary.employment_income_deductions
    end

    def total_outgoings_and_allowances
      net_housing_costs + dependant_allowance + child_care_bank + maintenance_out_bank + legal_aid_bank\
      + @monthly_cash_transactions_total - fixed_employment_allowance - employment_income_deductions
    end

    def disposable_income
      [0, total_gross_income - total_outgoings_and_allowances].max
    end
  end
end
