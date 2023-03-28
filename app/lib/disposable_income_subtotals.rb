class DisposableIncomeSubtotals
  attr_reader :dependant_allowance, :partner_dependant_allowance

  def initialize(dependant_allowance: 0, partner_dependant_allowance: 0)
    @dependant_allowance = dependant_allowance
    @partner_dependant_allowance = partner_dependant_allowance
  end
end
