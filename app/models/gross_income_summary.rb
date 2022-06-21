class GrossIncomeSummary < ApplicationRecord
  belongs_to :assessment
  has_many :state_benefits, dependent: :destroy
  has_many :other_income_sources, dependent: :destroy
  has_many :irregular_income_payments, dependent: :destroy
  has_many :cash_transaction_categories, dependent: :destroy
  has_many :eligibilities,
           class_name: "Eligibility::GrossIncome",
           inverse_of: :gross_income_summary,
           foreign_key: :parent_id,
           dependent: :destroy
  has_one :crime_eligibility,
          class_name: "Eligibility::AdjustedIncome",
          inverse_of: :gross_income_summary,
          foreign_key: :parent_id,
          dependent: :destroy

  def housing_benefit_payments
    state_benefits.find_by(state_benefit_type_id: StateBenefitType.housing_benefit&.id)&.state_benefit_payments || []
  end

  def summarized_assessment_result
    Utilities::ResultSummarizer.call(eligibilities.map(&:assessment_result))
  end

  def crime_summarized_assessment_result
    crime_eligibility.assessment_result.to_sym
  end

  def eligible?
    summarized_assessment_result.in? %i[eligible partially_eligible]
  end
end
