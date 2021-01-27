class CapitalSummary < ApplicationRecord
  extend EnumHash

  belongs_to :assessment

  has_many :capital_items, dependent: :destroy
  has_many :liquid_capital_items, dependent: :destroy
  has_many :non_liquid_capital_items, dependent: :destroy
  has_many :vehicles, dependent: :destroy
  has_many :properties, dependent: :destroy
  has_many :additional_properties, -> { additional }, inverse_of: :capital_summary, class_name: 'Property', dependent: :destroy
  has_one :main_home, -> { main_home }, inverse_of: :capital_summary, class_name: 'Property', dependent: :destroy

  enum(
    assessment_result: enum_hash_for(
      :pending, :eligible, :ineligible, :contribution_required
    ),
    _prefix: false
  )
end
