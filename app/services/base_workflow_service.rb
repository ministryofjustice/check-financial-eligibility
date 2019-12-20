class BaseWorkflowService
  delegate :applicant,
           :capital_summary,
           :submission_date,
           :gross_income_summary, to: :assessment

  delegate :liquid_capital_items,
           :main_home,
           :additional_properties,
           :vehicles, to: :capital_summary

  delegate :upper_threshold,
           :state_benefits, to: :gross_income_summary

  attr_reader :assessment

  def self.call(*args)
    new(*args).call
  end

  def initialize(assessment)
    @assessment = assessment
  end

  def applicant
    @applicant = assessment.applicant
  end
end
