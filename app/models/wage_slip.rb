class WageSlip < ApplicationRecord
  belongs_to :assessment

  validate :payment_date_cannot_be_in_future

  def payment_date_cannot_be_in_future
    if payment_date > Date.today
      errors.add(:base, 'Wage slip payment date cannot be in the future')
    end
  end
end
