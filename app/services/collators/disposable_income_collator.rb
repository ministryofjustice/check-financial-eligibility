module Collators
  class DisposableIncomeCollator
    Attrs = Data.define(:attrs, :monthly_cash_transactions_total)

    class << self
      def call(disposable_income_summary:, gross_income_summary:, partner_allowance:, gross_income_subtotals:, outgoings:)
        new(gross_income_summary:, disposable_income_summary:, partner_allowance:, gross_income_subtotals:, outgoings:).call
      end
    end

    def initialize(disposable_income_summary:, gross_income_summary:, partner_allowance:, gross_income_subtotals:, outgoings:)
      @disposable_income_summary = disposable_income_summary
      @gross_income_summary = gross_income_summary
      @partner_allowance = partner_allowance
      @gross_income_subtotals = gross_income_subtotals
      @outgoings = outgoings
    end

    def call
      attrs = populate_attrs
      @disposable_income_summary.update!(attrs.attrs)
      @disposable_income_summary.update!(
        total_outgoings_and_allowances: total_outgoings_and_allowances(attrs.monthly_cash_transactions_total),
        total_disposable_income: disposable_income(attrs.monthly_cash_transactions_total),
      )
    end

  private

    def outgoing_categories
      CFEConstants::VALID_OUTGOING_CATEGORIES.map(&:to_sym)
    end

    # TODO: This line seems redundant as it updates the column to its existing value!
    # `attrs[:"#{category}_bank"] = __send__("#{category}_bank")`
    def populate_attrs
      attrs = {}
      monthly_cash_transactions_total = 0

      outgoing_categories.each do |category|
        monthly_cash_amount = monthly_cash_by_category(category)
        monthly_cash_transactions_total += monthly_cash_amount unless category == :rent_or_mortgage

        attrs[:"#{category}_bank"] = @disposable_income_summary.public_send("#{category}_bank")
        attrs[:"#{category}_cash"] = monthly_cash_amount
        attrs[:"#{category}_all_sources"] = attrs[:"#{category}_bank"] + attrs[:"#{category}_cash"]
      end

      Attrs.new(attrs:, monthly_cash_transactions_total:)
    end

    def monthly_cash_by_category(category)
      if category == :child_care
        @disposable_income_summary.child_care_cash
      else
        Calculators::MonthlyCashTransactionAmountCalculator.call(gross_income_summary: @gross_income_summary, operation: :debit, category:)
      end
    end

    def total_outgoings_and_allowances(monthly_cash_transactions_total)
      @disposable_income_summary.net_housing_costs +
        @outgoings.dependant_allowance +
        monthly_bank_transactions_total +
        monthly_cash_transactions_total -
        @gross_income_subtotals.employment_income_subtotals.fixed_employment_allowance -
        @gross_income_subtotals.employment_income_subtotals.employment_income_deductions +
        @partner_allowance
    end

    def monthly_bank_transactions_total
      @disposable_income_summary.child_care_bank +
        @disposable_income_summary.maintenance_out_bank +
        @disposable_income_summary.legal_aid_bank
    end

    def disposable_income(monthly_cash_transactions_total)
      @gross_income_subtotals.total_gross_income - total_outgoings_and_allowances(monthly_cash_transactions_total)
    end
  end
end
