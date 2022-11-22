module Collators
  class ChildcareCollator
    include Transactions

    class << self
      def call(submission_date:, disposable_income_summary:, gross_income_summary:, person:)
        new(submission_date:, disposable_income_summary:, gross_income_summary:, person:).call
      end
    end

    def initialize(submission_date:, disposable_income_summary:, gross_income_summary:, person:)
      @submission_date = submission_date
      @disposable_income_summary = disposable_income_summary
      @gross_income_summary = gross_income_summary
      @person = person
    end

    def call
      @disposable_income_summary.calculate_monthly_childcare_amount!(eligible_for_childcare_costs?, monthly_child_care_cash)
    end

  private

    def eligible_for_childcare_costs?
      person_has_dependant_child? && (person_is_employed? || person_has_student_loan?)
    end

    def monthly_child_care_cash
      monthly_cash_transaction_amount_by(gross_income_summary: @gross_income_summary, operation: :debit, category: :child_care)
    end

    def person_has_dependant_child?
      @person.dependants.any? do |dependant|
        @submission_date.before?(dependant.becomes_adult_on)
      end
    end

    def person_is_employed?
      @person.employed?
    end

    def person_has_student_loan?
      @person.has_student_loan?
    end
  end
end
