# Sum convert each regular income transaction to monthly, sum together in <category>_all_sources
# with any pre-existing values from other transaction forms (cash typically)
#
# for each category:
# 1. retrieve a set of all regular transactions of that category/operation
# 2. for each set convert amount to monthly from whatever frequency it is
# 3. sum all monthly amounts for the category/operation
# 4. sum that value to the `<category>_all_sources:` key's value
# 5. sum that value to `total_gross_income` aswell
# 6. update that `<category>_all_sources` and `total_gross_income` column values on DB
#
module Collators
  class RegularIncomeCollator < BaseWorkflowService
    include MonthlyEquivalentCalculatable

    def call
      gross_income_summary.update!(gross_income_attributes)
    end

  private

    # TODO: use same method in GrossIncomeCollator to avoid leaky/redefining constants or promote?!
    def income_categories
      CFEConstants::VALID_INCOME_CATEGORIES.map(&:to_sym)
    end

    def gross_income_attributes
      attrs = initialize_attributes

      income_categories.each do |category|
        category_all_sources = "#{category}_all_sources".to_sym
        category_monthly_amount = monthly_regular_transaction_amount_by(operation: :credit, category:)

        attrs[category_all_sources] += category_monthly_amount
        attrs[:total_gross_income] += category_monthly_amount
      end

      attrs
    end

    def initialize_attributes
      income_categories.each_with_object({}) { |category, attrs|
        attrs["#{category}_all_sources"] = gross_income_summary.send("#{category}_all_sources")
        attrs[:total_gross_income] = gross_income_summary.total_gross_income
      }.symbolize_keys
    end

    # TODO: share with RegularOutgoingsCollator, when it is created?!
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
