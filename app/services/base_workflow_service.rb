class BaseWorkflowService
  delegate :applicant, :capital_summary, to: :assessment
  delegate :liquid_capital_items, :main_home, :additional_properties, :vehicles, to: :capital_summary

  attr_reader :assessment

  def initialize(assessment)
    @assessment = assessment
    @submission_date = @assessment.submission_date
    @calculation_period = CalculationPeriod.new(@submission_date)
  end
end
