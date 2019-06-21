class BenefitReceipt < ApplicationRecord
  belongs_to :assessment

  validate :payment_date_cannot_be_in_future

  def payment_date_cannot_be_in_future
    errors.add(:base, 'Benefit payment date cannot be in the future') if payment_date > Date.today
  end
end
