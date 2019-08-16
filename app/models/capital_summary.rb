class CapitalSummary < ApplicationRecord
  belongs_to :assessment

  has_many :capital_items
  has_many :liquid_capital_items
  has_many :non_liquid_capital_items
  has_many :vehicles
  has_many :properties
  has_many :additional_properties, -> { where(main_home: false) }, class_name: 'Property'

  enum(
    capital_assessment_result: {
      pending: 'pending'.freeze,
      summarised: 'summarised'.freeze,
      eligible: 'eligible'.freeze,
      not_eligible: 'not eligible'.freeze,
      contribution_required: 'contribution required'.freeze
    },
    _prefix: false
  )

  def main_home
    properties.where(main_home: true).first
  end
end
