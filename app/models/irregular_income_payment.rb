class IrregularIncomePayment < ApplicationRecord
  belongs_to :gross_income_summary

  validates :income_type, inclusion: { in: CFEConstants::VALID_IRREGULAR_INCOME_TYPES }
  validates :frequency, inclusion: { in: CFEConstants::VALID_IRREGULAR_INCOME_FREQUENCIES }
  validates :amount, numericality: { greater_than_or_equal_to: 0 }

  scope :student_loan, -> { where(income_type: CFEConstants::STUDENT_LOAN) }
  scope :unspecified, -> { where(income_type: CFEConstants::UNSPECIFIED_SOURCE_INCOME) }
end
