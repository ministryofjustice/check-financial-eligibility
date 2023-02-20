class CalculationOutput
  def initialize(gross_income_subtotals: nil, capital_subtotals: nil)
    @capital_subtotals = capital_subtotals || CapitalSubtotals.new
    @gross_income_subtotals = gross_income_subtotals || GrossIncomeSubtotals.new
  end

  attr_reader :capital_subtotals, :gross_income_subtotals
end
