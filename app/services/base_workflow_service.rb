class BaseWorkflowService
  def initialize(particulars)
    @particulars = particulars
    @submission_date = @particulars.request.meta_data.submission_date
    @calculation_period = CalculationPeriod.new(@submission_date)
  end
end
