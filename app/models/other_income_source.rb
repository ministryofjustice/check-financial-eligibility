class OtherIncomeSource < ApplicationRecord
  belongs_to :gross_income_summary
  has_many :other_income_payments

  validates :gross_income_summary_id, :name, presence: true
end
