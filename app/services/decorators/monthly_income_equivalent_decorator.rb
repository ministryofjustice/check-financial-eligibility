module Decorators
  class MonthlyIncomeEquivalentDecorator
    attr_reader :record

    def initialize(gross_income_summary)
      @record = gross_income_summary
    end

    def as_json
      {
        friends_or_family: record.friends_or_family,
        maintenance_in: record.maintenance_in,
        property_or_lodger: record.property_or_lodger,
        pension: record.pension
      }.merge(student_loan)
    end

    private

    # TODO: remove student loan when irregular income handles it
    def student_loan
      return {} if record.irregular_income_payments.present?

      {
        student_loan: record.student_loan
      }
    end
  end
end
