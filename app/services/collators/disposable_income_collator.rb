module Collators
  class DisposableIncomeCollator < BaseWorkflowService
    include Transactions

    attr_reader :monthly_cash_transactions_total

    delegate :net_housing_costs,
             :rent_or_mortgage_bank,
             :rent_or_mortgage_cash,
             :child_care_bank,
             :child_care_cash,
             :maintenance_out_bank,
             :maintenance_out_cash,
             :dependant_allowance,
             :legal_aid_bank,
             :legal_aid_cash,
             :fixed_employment_allowance,
             :employment_income_deductions, to: :disposable_income_summary

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

    def outgoing_categories
      CFEConstants::VALID_OUTGOING_CATEGORIES.map(&:to_sym)
    end

    def populate_attrs
      attrs = {}

      outgoing_categories.each do |category|
        monthly_cash_amount = category == :child_care ? __send__("#{category}_cash") : monthly_cash_by_category(category)
        @monthly_cash_transactions_total += monthly_cash_amount unless category == :rent_or_mortgage

        attrs[:"#{category}_cash"] = monthly_cash_amount
        attrs[:"#{category}_all_sources"] = bank_amount_for(category) + attrs[:"#{category}_cash"]
      end

      attrs.merge(default_attrs)
    end

    def bank_amount_for(category)
      __send__("#{category}_bank")
    end

    def monthly_cash_by_category(category)
      monthly_cash_transaction_amount_by(operation: :debit, category:)
    end

    def default_attrs
      {
        total_outgoings_and_allowances:,
        total_disposable_income: disposable_income,
      }
    end

    def total_outgoings_and_allowances
      net_housing_costs +
        dependant_allowance +
        monthly_bank_transactions_total +
        monthly_cash_transactions_total -
        fixed_employment_allowance -
        employment_income_deductions
    end

    def monthly_bank_transactions_total
      child_care_bank + maintenance_out_bank + legal_aid_bank
    end

    def disposable_income
      total_gross_income - total_outgoings_and_allowances
    end
  end
end
