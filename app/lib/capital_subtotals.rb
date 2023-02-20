class CapitalSubtotals
  def initialize(applicant_capital_subtotals: nil, partner_capital_subtotals: nil, capital_contribution: nil, combined_assessed_capital: nil)
    @applicant_capital_subtotals = applicant_capital_subtotals || PersonCapitalSubtotals.new
    @partner_capital_subtotals = partner_capital_subtotals || PersonCapitalSubtotals.new
    @capital_contribution = capital_contribution || 0
    @combined_assessed_capital = combined_assessed_capital || 0
  end

  attr_reader :applicant_capital_subtotals, :partner_capital_subtotals, :capital_contribution, :combined_assessed_capital
end
