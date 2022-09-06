# Sum convert each regular outgoings transaction to monthly, sum together in <category>_all_sources
# with any pre-existing values from other transaction forms (cash typically)
#
# for each category:
# 1. retrieve a set of all regular transactions of that category/operation
# 2. for each set convert amount to monthly from whatever frequency it is
# 3. sum all monthly amounts for that category/operation
# 4. sum that value to the `<category>_all_sources:` key's value
# 5. sum that value to `total_outgoings_and_allowances` aswell
# 6. amend value of `total_disposable_income` (to be `total_gross_income - total_outgoings_and_allowances`)
# 7. update that `<category>_all_sources`, `total_outgoings_and_allowances` and `total_disposable_income` column values on DB
#
module Collators
  class RegularOutgoingsCollator < BaseWorkflowService
    include MonthlyEquivalentCalculatable

    def call
      disposable_income_summary.update!(disposable_income_attributes)
    end

  private

    # TODO: use same method in DisposableIncomeCollator to avoid leaky/redefining constants or promote?!
    def outgoing_categories
      CFEConstants::VALID_OUTGOING_CATEGORIES.map(&:to_sym)
    end

    def disposable_income_attributes
      attrs = initialize_attributes

      outgoing_categories.each do |category|
        category_all_sources = "#{category}_all_sources".to_sym
        category_monthly_amount = monthly_regular_transaction_amount_by(operation: :debit, category:)

        attrs[category_all_sources] += category_monthly_amount
        attrs[:total_outgoings_and_allowances] += category_monthly_amount
        attrs[:total_disposable_income] -= category_monthly_amount
      end

      attrs
    end

    def initialize_attributes
      attrs = outgoing_categories.each_with_object({}) { |category, dict|
        dict["#{category}_all_sources"] = disposable_income_summary.send("#{category}_all_sources")
      }.symbolize_keys

      attrs[:total_outgoings_and_allowances] = disposable_income_summary.total_outgoings_and_allowances
      attrs[:total_disposable_income] = disposable_income_summary.total_disposable_income
      attrs
    end

    # TODO: share with RegularOutgoingsCollator, when it is created?!
    # TODO: delegate regular_transactions to gross_income_summary in superclass
    def monthly_regular_transaction_amount_by(operation:, category:)
      transactions = gross_income_summary.regular_transactions.where(operation:).where(category:)

      all_monthly_amounts = transactions.each_with_object([]) do |transaction, amounts|
        calc_method = determine_calc_method(transaction.frequency)
        amounts << send(calc_method, transaction.amount)
      end

      all_monthly_amounts.sum
    end
  end
end
