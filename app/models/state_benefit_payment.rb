class StateBenefitPayment < ApplicationRecord
  belongs_to :state_benefit

  validates :payment_date, presence: true, date: {
    before: proc { Time.zone.tomorrow }, message: "cannot be in the future"
  }
end
