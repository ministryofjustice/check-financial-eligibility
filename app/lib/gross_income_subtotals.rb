class GrossIncomeSubtotals
  attr_reader :applicant_gross_income_subtotals, :partner_gross_income_subtotals

  def initialize(applicant_gross_income_subtotals: nil, partner_gross_income_subtotals: nil)
    @applicant_gross_income_subtotals = applicant_gross_income_subtotals || PersonGrossIncomeSubtotals.new
    @partner_gross_income_subtotals = partner_gross_income_subtotals || PersonGrossIncomeSubtotals.new
  end

  def combined_monthly_gross_income
    @applicant_gross_income_subtotals.total_gross_income + @partner_gross_income_subtotals.total_gross_income
  end
end
