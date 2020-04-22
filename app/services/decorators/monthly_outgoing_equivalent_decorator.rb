module Decorators
  class MonthlyOutgoingEquivalentDecorator
    def initialize(disposable_income_summary)
      @record = disposable_income_summary
    end

    def as_json
      {
        child_care: @record.childcare,
        maintenance_out: @record.maintenance,
        rent_or_mortgage: @record.gross_housing_costs,
        legal_aid: @record.legal_aid
      }
    end
  end
end
