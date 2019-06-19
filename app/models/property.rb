class Property < ApplicationRecord
  # belongs_to :asssessment

  validates :value, numericality: { greater_than: 0 }
  validates :outstanding_mortgage, numericality: { greater_than_or_equal_to: 0 }
  validates :percentage_owned, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  validates :main_home, :shared_with_housing_assoc, inclusion: { in: [true, false] }
end
