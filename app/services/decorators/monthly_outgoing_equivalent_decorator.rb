module Decorators
  class MonthlyOutgoingEquivalentDecorator
    include Transactions

    attr_reader :record, :categories

    def initialize(disposable_income_summary)
      @record = disposable_income_summary
      @categories = CFEConstants::VALID_OUTGOING_CATEGORIES.map(&:to_sym)
    end

    def as_json
      all_transaction_types
    end
  end
end
