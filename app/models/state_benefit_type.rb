class StateBenefitType < ApplicationRecord
  validates :label, uniqueness: true, presence: true
  validates :name, presence: true
end
