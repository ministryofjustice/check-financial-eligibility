class CashTransactionCategory < ApplicationRecord
  belongs_to :gross_income_summary

  validates :operation, inclusion: { in: %w(credit debit),
                                message: "%{value} is not a valid operation" }


end

