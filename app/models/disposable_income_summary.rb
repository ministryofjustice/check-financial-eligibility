class DisposableIncomeSummary < ApplicationRecord
  extend EnumHash

  belongs_to :assessment
  has_many :outgoings, dependent: :destroy, class_name: "Outgoings::BaseOutgoing"
  has_many :childcare_outgoings, dependent: :destroy, class_name: "Outgoings::Childcare"
  has_many :housing_cost_outgoings, dependent: :destroy, class_name: "Outgoings::HousingCost"
  has_many :maintenance_outgoings, dependent: :destroy, class_name: "Outgoings::Maintenance"
  has_many :legal_aid_outgoings, dependent: :destroy, class_name: "Outgoings::LegalAid"
  has_many :eligibilities,
           class_name: "Eligibility::DisposableIncome",
           inverse_of: :disposable_income_summary,
           foreign_key: :parent_id,
           dependent: :destroy

  def summarized_assessment_result
    Utilities::ResultSummarizer.call(eligibilities.map(&:assessment_result))
  end

  def ineligible?
    summarized_assessment_result == :ineligible
  end
end
