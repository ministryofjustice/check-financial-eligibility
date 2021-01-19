class GrossIncomeSummary < ApplicationRecord
  extend EnumHash

  belongs_to :assessment
  has_many :state_benefits
  has_many :other_income_sources
  has_many :irregular_income_payments
  has_many :cash_transaction_categories

  enum(
    assessment_result: enum_hash_for(
      :pending, :eligible, :ineligible, :summarised
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
