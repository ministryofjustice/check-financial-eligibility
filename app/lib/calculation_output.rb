class CalculationOutput
  delegate :dependant_allowance, :partner_dependant_allowance, to: :@disposable_income_subtotals

  def initialize(gross_income_subtotals: nil, capital_subtotals: nil, disposable_income_subtotals: nil)
    @capital_subtotals = capital_subtotals || CapitalSubtotals.new
    @gross_income_subtotals = gross_income_subtotals || GrossIncomeSubtotals.new
    @disposable_income_subtotals = disposable_income_subtotals || DisposableIncomeSubtotals.new
  end

  attr_reader :capital_subtotals, :gross_income_subtotals
end
