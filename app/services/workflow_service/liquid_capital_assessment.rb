module WorkflowService
  class LiquidCapitalAssessment
    def initialize(assessment_id)
      @assessment = Assessment.find assessment_id
    end

    def call
      total_liquid_capital = 0.0
      @assessment.bank_accounts.each do |acct|
        total_liquid_capital += acct.lowest_balance if acct.lowest_balance.positive?
      end
      total_liquid_capital.round(2)
    end
  end
end
