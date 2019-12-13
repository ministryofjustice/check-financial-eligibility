class GrossIncomeSummary < ApplicationRecord
  belongs_to :assessment
  has_many :state_benefits
  has_many :other_income_sources

  def summarise!
    data = WorkflowService::GrossIncomeCollator.call(assessment)
    update!(data)
  end
end
