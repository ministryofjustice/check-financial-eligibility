class CapitalSummary < ApplicationRecord
  extend EnumHash

  belongs_to :assessment

  has_many :capital_items
  has_many :liquid_capital_items
  has_many :non_liquid_capital_items
  has_many :vehicles
  has_many :properties
  has_many :additional_properties, -> { additional }, class_name: 'Property'
  has_one :main_home, -> { main_home }, class_name: 'Property'

  enum(
    assessment_result: enum_hash_for(
      :pending, :eligible, :not_eligible, :contribution_required
    ),
    _prefix: false
  )
end
