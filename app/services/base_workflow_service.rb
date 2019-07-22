class BaseWorkflowService
  attr_accessor :particulars

  REQUEST_METHODS = %i[meta_data applicant applicant_income applicant_outgoings applicant_capital].freeze
  RESPONSE_METHODS = %i[response_capital response_income response_contributions].freeze

  def initialize(assessment)
    @assessment = assessment
    @calculation_period = CalculationPeriod.new(@assessment.submission_date)
  end
end
