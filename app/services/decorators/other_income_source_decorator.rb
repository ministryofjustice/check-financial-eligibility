module Decorators
  class OtherIncomeSourceDecorator
    include Transactions

    attr_reader :record, :categories

    def initialize(record)
      @record = record
      @categories = income_categories_excluding_benefits
    end

    def as_json
      {
        monthly_equivalents: all_transaction_types
      }
    end

    private

    def income_categories_excluding_benefits
      CFEConstants::VALID_INCOME_CATEGORIES.map(&:to_sym) - [:benefits]
    end
  end
end
