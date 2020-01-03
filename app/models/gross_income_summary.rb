class GrossIncomeSummary < ApplicationRecord
  extend EnumHash

  belongs_to :assessment
  has_many :state_benefits
  has_many :other_income_sources

  enum(
    assessment_result: enum_hash_for(
      :pending, :summarised, :eligible, :not_eligible, :not_applicable
    ),
    _prefix: false
  )

  def summarise!
    data = Collators::GrossIncomeCollator.call(assessment)
    update!(data)
  end

  def housing_benefit_payments
    state_benefits.find_by(state_benefit_type_id: StateBenefitType.housing_benefit&.id)&.state_benefit_payments || []
  end
end
