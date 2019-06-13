class DependentIncomeReceipt < ApplicationRecord
  belongs_to :dependent

  validate :date_of_payment_cannot_be_in_future

  def date_of_payment_cannot_be_in_future
    errors.add(:date_of_payment, 'cannot be in the future') if date_of_payment > Date.today
  end
end
