class CapitalSummary < ApplicationRecord
  extend EnumHash

  belongs_to :assessment

  has_many :capital_items
  has_many :liquid_capital_items
  has_many :non_liquid_capital_items
  has_many :vehicles
  has_many :properties
  has_many :additional_properties, -> { where(main_home: false) }, class_name: 'Property'

  enum capital_assessment_result: enum_hash_for(:pending, :summarised, :eligible, :not_eligible, :contribution_required), _prefix: false

  def main_home
    properties.find_by(main_home: true)
  end

  def sum_totals!
    self.total_capital = total_liquid +
                         total_non_liquid +
                         total_vehicle +
                         total_property
  end

  def assess_capital!
    apply_pensioner_disregard

    apply_thresholds
  end

  private

  def apply_pensioner_disregard
    self.pensioner_capital_disregard = WorkflowService::PensionerCapitalDisregard.new(assessment).value
  end

  def calculate_assessed_capital
    self.assessed_capital = total_capital - pensioner_capital_disregard
  end

  def apply_thresholds
    self.lower_threshold = Threshold.value_for(:capital_lower, at: assessment.submission_date)
    self.upper_threshold = Threshold.value_for(:capital_upper, at: assessment.submission_date)
  end
end
