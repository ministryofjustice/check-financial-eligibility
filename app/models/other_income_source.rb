class OtherIncomeSource < ApplicationRecord
  belongs_to :gross_income_summary
  has_many :other_income_payments, dependent: :destroy

  validates :name, inclusion: { in: CFEConstants::HUMANIZED_INCOME_CATEGORIES }

  delegate :assessment, to: :gross_income_summary
end
