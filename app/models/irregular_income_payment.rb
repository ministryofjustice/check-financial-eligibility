class IrregularIncomePayment < ApplicationRecord
  ANNUAL_FREQUENCY = 'annual'.freeze
  STUDENT_LOAN = 'student_loan'.freeze
  VALID_IRREGULAR_INCOME_FREQUENCIES = [ANNUAL_FREQUENCY].freeze
  VALID_IRREGULAR_INCOME_TYPES = [STUDENT_LOAN].freeze

  belongs_to :gross_income_summary

  validates :income_type, inclusion: { in: VALID_IRREGULAR_INCOME_TYPES }
  validates :frequency, inclusion: { in: VALID_IRREGULAR_INCOME_FREQUENCIES }
  validates :amount, numericality: { greater_than_or_equal_to: 0 }
end
