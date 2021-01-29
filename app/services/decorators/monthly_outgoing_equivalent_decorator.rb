module Decorators
  class MonthlyOutgoingEquivalentDecorator
    include Transactions

    attr_reader :record, :categories

    def initialize(disposable_income_summary)
      @record = disposable_income_summary
      @categories = CFEConstants::VALID_OUTGOING_CATEGORIES.map(&:to_sym)
    end

    def as_json
      case record.version
      when CFEConstants::LATEST_ASSESSMENT_VERSION
        payload_v3
      else
        payload_v2
      end
    end

    private

    def payload_v2
      {
        child_care: record.child_care_bank,
        maintenance_out: record.maintenance_out_bank,
        rent_or_mortgage: record.rent_or_mortgage_bank,
        legal_aid: record.legal_aid_bank
      }
    end

    def payload_v3
      all_transaction_types
    end
  end
end
