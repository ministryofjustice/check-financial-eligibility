class StateBenefitType < ApplicationRecord
  validates :label, uniqueness: true, presence: true
  validates :name, presence: true

  def self.housing_benefit
    find_by(label: 'housing_benefit')
  end

  def self.as_cfe_json
    all.map(&:as_cfe_json)
  end

  def as_cfe_json
    as_json(only: %i[name label dwp_code])
  end
end
