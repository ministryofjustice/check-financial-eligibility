class CashTransactionCategory < ApplicationRecord
  belongs_to :gross_income_summary
  has_many :cash_transactions

  validates :operation, inclusion: { in: %w[credit debit],
                                     message: '%{value} is not a valid operation' }

  validates :name, presence: true
end
