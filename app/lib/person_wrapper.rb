# used to convert DB layer into domain layer for rules
class PersonWrapper
  delegate :employed?, to: :@person

  attr_reader :dependants

  def initialize(person:, is_single:, dependants:, gross_income_summary:)
    @person = person
    @is_single = is_single
    @dependants = dependants
    @gross_income_summary = gross_income_summary
  end

  def has_student_loan?
    @gross_income_summary.student_loan_payments.any?
  end

  def single?
    @is_single
  end
end
