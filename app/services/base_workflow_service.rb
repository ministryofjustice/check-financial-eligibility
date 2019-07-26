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

  def non_liquid_assets
    @non_liquid_assets ||= @assessment.non_liquid_assets
  end

  def result
    @result ||= @assessment.result
  end

  def main_home
    @main_home ||= @assessment.properties.find_by(main_home: true)
  end

  def additional_properties
    @additional_properties ||= @assessment.properties.where(main_home: false)
  end
end
