class BenefitReceipt < ApplicationRecord
  extend EnumHash
  belongs_to :assessment

  enum benefit_name: enum_hash_for(:child_benefit, :jobseekers_allowance, :universal_credit)

  validate :payment_date_cannot_be_in_future

  def payment_date_cannot_be_in_future
    errors.add(:base, 'Benefit payment date cannot be in the future') if payment_date > Date.today
  end
end
