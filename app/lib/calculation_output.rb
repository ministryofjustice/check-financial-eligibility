class CalculationOutput
  def initialize(capital_subtotals: CapitalSubtotals.new)
    @capital_subtotals = capital_subtotals
  end

  attr_reader :capital_subtotals
end
