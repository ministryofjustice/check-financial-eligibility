class BaseWorkflowService
  def initialize(assessment)
    @assessment = assessment
    @submission_date = @assessment.submission_date
    @calculation_period = CalculationPeriod.new(@submission_date)
  end

  private

  attr_reader :assessment

  def applicant
    @applicant ||= @assessment.applicant
  end

  def liquid_capital_items
    @liquid_capital_items ||= capital_summary.liquid_capital_items
  end

  def main_home
    @main_home ||= capital_summary.main_home
  end

  def additional_properties
    @additional_properties ||= capital_summary.additional_properties
  end

  def vehicles
    @vehicles ||= capital_summary.vehicles
  end

  def capital_summary
    @capital_summary ||= @assessment.capital_summary
  end
end
