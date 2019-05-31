class BaseWorkflowService
  def initialize(particulars)
    @particulars = particulars
    @submission_date = Date.parse(@particulars.request.meta_data.submission_date)
    @calculation_period = CalculationPeriod.new(@submission_date)
  end
end
