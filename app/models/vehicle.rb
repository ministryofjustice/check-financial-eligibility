class Vehicle < ApplicationRecord
  belongs_to :capital_summary

  validate :date_of_purchase_cannot_be_in_future

  def date_of_purchase_cannot_be_in_future
    errors.add(:date_of_purchase, 'cannot be in the future') if date_of_purchase > Date.today
  end
end
