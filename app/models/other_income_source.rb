class OtherIncomeSource < ApplicationRecord
  include MonthlyEquivalentCalculator

  VALID_INCOME_SOURCES = %w[friends_or_family maintenance_in property_or_lodger student_loan pension].freeze

  belongs_to :gross_income_summary
  has_many :other_income_payments

  validates :gross_income_summary_id, :name, presence: true
  validates :name, inclusion: { in: VALID_INCOME_SOURCES }

  delegate :assessment, to: :gross_income_summary

  def student_payment?
    name.in? %w[student_grant student_loan]
  end

  def calculate_monthly_income!
    calculate_monthly_equivalent!(target_field: :monthly_income,
                                  collection: other_income_payments)
  end
end
