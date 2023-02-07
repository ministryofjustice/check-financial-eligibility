class CapitalSubtotals
  def initialize(applicant_capital_subtotals:, partner_capital_subtotals: nil, capital_contribution: nil, combined_assessed_capital: nil)
    @applicant_capital_subtotals = applicant_capital_subtotals
    @partner_capital_subtotals = partner_capital_subtotals
    @capital_contribution = capital_contribution
    @combined_assessed_capital = combined_assessed_capital
  end

  attr_reader :applicant_capital_subtotals, :partner_capital_subtotals, :capital_contribution, :combined_assessed_capital
end
