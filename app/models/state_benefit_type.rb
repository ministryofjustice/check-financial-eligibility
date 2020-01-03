class StateBenefitType < ApplicationRecord
  validates :label, uniqueness: true, presence: true
  validates :name, presence: true

  def self.housing_benefit
    find_by(label: 'housing_benefit')
  end
end
