class BaseWorkflowService
  attr_accessor :particulars

  def initialize(assessment)
    @assessment = assessment
    @calculation_period = CalculationPeriod.new(@assessment.submission_date)
  end
end
