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
    capital_assessment_result: enum_hash_for(
      :pending, :summarised, :eligible, :not_eligible, :contribution_required
    ),
    _prefix: false
  )

  def summarise!
    data = Collators::CapitalCollator.call(assessment)
    update!(data) && summarised!
  end

  def determine_result!
    update!(capital_assessment_result: result)
  end

  private

  def result
    return :eligible if assessed_capital <= lower_threshold

    :contribution_required
  end
end
