# Convert each regular outgoing to monthly and sum together in
# <category>_all_sources with any pre-existing values from other
# transactions (cash typically). Also, except for :rent_or_mortgate**,
# increment the total_outgoings_and_allowances and decrement the total_disposable_income.
#
# ** :rent_or_mortgage that has already been added to totals by the
# HousingCostCollator/HousingCostCalculator and DisposableIncomeCollator :(
#
module Collators
  class RegularOutgoingsCollator
    class << self
      def call(disposable_income_summary:, gross_income_summary:)
        new(disposable_income_summary:, gross_income_summary:).call
      end
    end

    include MonthlyEquivalentCalculatable

    def initialize(disposable_income_summary:, gross_income_summary:)
      @disposable_income_summary = disposable_income_summary
      @gross_income_summary = gross_income_summary
    end

    def call
      @disposable_income_summary.update!(disposable_income_attributes)
    end

  private

    def outgoing_categories
      CFEConstants::VALID_OUTGOING_CATEGORIES.map(&:to_sym)
    end

    def disposable_income_attributes
      attrs = initialize_attributes

      outgoing_categories.each do |category|
        category_all_sources = "#{category}_all_sources".to_sym
        category_monthly_amount = monthly_regular_transaction_amount_by(gross_income_summary: @gross_income_summary, operation: :debit, category:)

        attrs[category_all_sources] += category_monthly_amount
        next if category == :rent_or_mortgage # see ** above

        attrs[:total_outgoings_and_allowances] += category_monthly_amount
        attrs[:total_disposable_income] -= category_monthly_amount
      end

      attrs
    end

    def initialize_attributes
      attrs = outgoing_categories.each_with_object({}) { |category, dict|
        dict["#{category}_all_sources"] = @disposable_income_summary.send("#{category}_all_sources")
      }.symbolize_keys

      attrs[:total_outgoings_and_allowances] = @disposable_income_summary.total_outgoings_and_allowances
      attrs[:total_disposable_income] = @disposable_income_summary.total_disposable_income
      attrs
    end
  end
end
