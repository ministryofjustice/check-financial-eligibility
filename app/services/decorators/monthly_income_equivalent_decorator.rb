module Decorators
  class MonthlyIncomeEquivalentDecorator
    def initialize(gross_income_summary)
      @record = gross_income_summary
    end

    def as_json
      {
        friends_or_family: @record.friends_or_family,
        maintenance_in: @record.maintenance_in,
        property_or_lodger: @record.property_or_lodger,
        student_loan: @record.student_loan,
        pension: @record.pension
      }
    end
  end
end
