class CapitalItem < ApplicationRecord
  validates :description, presence: true
  validates :value, presence: true

  belongs_to :capital_summary
end
