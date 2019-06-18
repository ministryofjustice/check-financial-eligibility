class Vehicle < ApplicationRecord
  belongs_to :assessment

  validates :value,
            :date_of_purchase, presence: true

  validates :in_regular_use, inclusion: { in: [true, false] }

  validate :date_of_purchase_cannot_be_in_future

  def date_of_purchase_cannot_be_in_future
    errors.add(:date_of_purchase, 'cannot be in the future') if date_of_purchase > Date.today
  end
end
