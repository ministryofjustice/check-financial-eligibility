class BenefitReceipt < ApplicationRecord
  belongs_to :assessment

  validate :payment_date_cannot_be_in_future

  def payment_date_cannot_be_in_future
    if payment_date > Date.today
      errors.add(:base, 'Benefit payment date cannot be in the future')
    end
  end
end
