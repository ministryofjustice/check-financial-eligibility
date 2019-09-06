class BaseWorkflowService
  delegate :applicant, :capital_summary, :submission_date, to: :assessment
  delegate :liquid_capital_items, :main_home, :additional_properties, :vehicles, to: :capital_summary

  attr_reader :assessment

  def self.call(*args)
    new(*args).call
  end

  def initialize(assessment)
    @assessment = assessment
  end

  def calculation_period
    @calculation_period ||= CalculationPeriod.new(submission_date)
  end
end
