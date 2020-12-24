class OtherIncomeSource < ApplicationRecord
  include MonthlyEquivalentCalculator

  belongs_to :gross_income_summary
  has_many :other_income_payments, dependent: :destroy

  validates :gross_income_summary_id, :name, presence: true
  validates :name, inclusion: { in: CFEConstants::HUMANIZED_INCOME_CATEGORIES }

  delegate :assessment, to: :gross_income_summary

  def calculate_monthly_income!
    calculate_monthly_equivalent!(target_field: :monthly_income,
                                  collection: other_income_payments)
  end
end
