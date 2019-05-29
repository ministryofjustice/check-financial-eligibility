module WorkflowService
  class DisposableCapitalAssessment < BaseWorkflowService
    def result_for
      calculate_liquid_capital
      true
    end

    private

    def calculate_liquid_capital
      total_liquid_capital = 0.0

      @particulars.request.applicant_capital.liquid_capital.bank_accounts.each do |acct|
        total_liquid_capital += acct.lowest_balance if acct.lowest_balance.positive?
      end
      @particulars.response.details.liquid_capital_assessment = total_liquid_capital.round(2)
    end
  end
end
