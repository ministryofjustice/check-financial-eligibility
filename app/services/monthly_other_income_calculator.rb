class MonthlyOtherIncomeCalculator
  def self.call(assessment_id)
    new(assessment_id).call
  end

  def initialize(assessment_id)
    @assessment = Assessment.find assessment_id
  end

  def call
    total_monthly_income = 0
    gross_income_summary.other_income_sources.each do |source|
      total_monthly_income += source.calculate_monthly_income!
    end
    gross_income_summary.update!(monthly_other_income: total_monthly_income)
  end

  private

  def gross_income_summary
    @gross_income_summary || @assessment.gross_income_summary
  end
end
