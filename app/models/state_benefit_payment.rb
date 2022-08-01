class StateBenefitPayment < ApplicationRecord
  belongs_to :state_benefit

  validates :payment_date, presence: true, cfe_date: { not_in_the_future: true }
end
