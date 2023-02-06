class CapitalSubtotals
  def initialize(applicant_capital_subtotals: PersonCapitalSubtotals.new, partner_capital_subtotals: PersonCapitalSubtotals.new)
    @applicant_capital_subtotals = applicant_capital_subtotals
    @partner_capital_subtotals = partner_capital_subtotals
  end

  attr_reader :applicant_capital_subtotals, :partner_capital_subtotals
end
