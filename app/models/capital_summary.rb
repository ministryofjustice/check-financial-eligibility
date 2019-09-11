class CapitalSummary < ApplicationRecord
  extend EnumHash

  belongs_to :assessment

  has_many :capital_items
  has_many :liquid_capital_items
  has_many :non_liquid_capital_items
  has_many :vehicles
  has_many :properties
  has_many :additional_properties, -> { where(main_home: false) }, class_name: 'Property'

  enum capital_assessment_result: enum_hash_for(:pending, :eligible, :not_eligible, :contribution_required), _prefix: false

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
    self.assessed_capital = total_capital - pensioner_capital_disregard
    apply_thresholds
    calculate_assessment_result
    calculate_contribution
  end

  def result # rubocop:disable Metrics/AbcSize
    {
      total_capital_assessment: total_capital.to_f,
      pensioner_capital_disregard: pensioner_capital_disregard.to_f,
      total_disposable_capital: assessed_capital.to_f,
      total_capital_test: capital_assessment_result.to_f,
      capital_contribution: capital_contribution.to_f,
      total_liquid_capital: total_liquid.to_f,
      liquid_capital_items: liquid_capital_items.map(&:result),
      total_non_liquid_capital: total_non_liquid.to_f,
      non_liquid_capital_items: non_liquid_capital_items.map(&:result),
      property: {
        total_property_assessment: total_property.to_f,
        total_mortgage_allowance: total_mortgage_allowance.to_f,
        additional_properties: additional_properties.map(&:result),
        main_home: main_home&.result
      },
      total_vehicles_value: total_vehicle.to_f,
      vehicles: vehicles.map(&:result)
    }
  end

  private

  def apply_pensioner_disregard
    self.pensioner_capital_disregard = WorkflowService::PensionerCapitalDisregard.new(assessment).value
  end

  def apply_thresholds
    self.lower_threshold = Threshold.value_for(:capital_lower, at: assessment.submission_date)
    self.upper_threshold = Threshold.value_for(:capital_upper, at: assessment.submission_date)
  end

  def calculate_assessment_result
    if assessed_capital < lower_threshold
      eligible!
    elsif assessed_capital < upper_threshold
      contribution_required!
    else
      not_eligible!
    end
  end

  def calculate_contribution
    self.capital_contribution = WorkflowService::CapitalContributionService.call(self) if contribution_required?
  end
end
