class CalculationOutput
  def initialize(capital_subtotals: nil)
    @capital_subtotals = capital_subtotals || instantiate_blank_capital_subtotals
  end

  attr_reader :capital_subtotals

private

  def instantiate_blank_capital_subtotals
    CapitalSubtotals.new(
      applicant_capital_subtotals: PersonCapitalSubtotals.new,
      partner_capital_subtotals: PersonCapitalSubtotals.new,
    )
  end
end
