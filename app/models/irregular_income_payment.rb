class IrregularIncomePayment < ApplicationRecord
  belongs_to :gross_income_summary

  validates :income_type, inclusion: { in: CFEConstants::VALID_IRREGULAR_INCOME_TYPES }
  validates :frequency, inclusion: { in: CFEConstants::VALID_IRREGULAR_INCOME_FREQUENCIES }
  validates :amount, numericality: { greater_than_or_equal_to: 0 }

  scope :student_loan, -> { where(income_type: CFEConstants::STUDENT_LOAN) }
  scope :unspecified_source, -> { where(income_type: CFEConstants::UNSPECIFIED_SOURCE) }

  MONTHS_PER_PERIOD = {
    CFEConstants::ANNUAL_FREQUENCY => 12,
    CFEConstants::QUARTERLY_FREQUENCY => 3,
    CFEConstants::MONTHLY_FREQUENCY => 1,
  }.freeze

  def monthly_equivalent_amount
    amount / MONTHS_PER_PERIOD.fetch(frequency)
  end
end
