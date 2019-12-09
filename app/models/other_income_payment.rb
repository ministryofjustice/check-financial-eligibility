class OtherIncomePayment < ApplicationRecord
  belongs_to :other_income_source

  validates :payment_date, :amount, presence: true
end
