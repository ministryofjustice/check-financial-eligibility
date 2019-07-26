class BaseWorkflowService
  def initialize(assessment)
    @assessment = assessment
    @submission_date = @assessment.submission_date
    @calculation_period = CalculationPeriod.new(@submission_date)
  end

  def applicant
    @applicant ||= @assessment.applicant
  end

  def bank_accounts
    @bank_accounts ||= @assessment.bank_accounts
  end
end
