class StateBenefitType < ApplicationRecord
  validates :label, uniqueness: true, presence: true
  validates :description, presence: true
end
