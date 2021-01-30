module Decorators
  class MonthlyOutgoingEquivalentDecorator
    include Transactions

    attr_reader :record, :categories

    def initialize(disposable_income_summary)
      @record = disposable_income_summary
      @categories = CFEConstants::VALID_OUTGOING_CATEGORIES.map(&:to_sym)
    end

    def as_json
      assessment_v3? ? all_transaction_types : all_transaction_types[:bank_transactions]
    end

    private

    def assessment_v3?
      record.version == CFEConstants::LATEST_ASSESSMENT_VERSION
    end
  end
end
