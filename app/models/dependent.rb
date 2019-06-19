class Dependent < ApplicationRecord
  belongs_to :assessment
  has_many :dependent_income_receipts
  accepts_nested_attributes_for :dependent_income_receipts

  validate :date_of_birth_in_past

  def date_of_birth_in_past
    errors.add(:date_of_birth, 'cannot be in future') if date_of_birth > Date.today
  end
end
