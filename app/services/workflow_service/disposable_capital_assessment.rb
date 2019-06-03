module WorkflowService
  class DisposableCapitalAssessment < BaseWorkflowService
    def call
      calculate_liquid_capital
      PropertyAssessment.new(@particulars).call
      VehicleAssessment.new(@particulars).call
      true
    end

    private

    def calculate_liquid_capital
      total_liquid_capital = 0.0

      applicant_capital.liquid_capital.bank_accounts.each do |acct|
        total_liquid_capital += acct.lowest_balance if acct.lowest_balance.positive?
      end
      response.details.liquid_capital_assessment = total_liquid_capital.round(2)
    end
  end
end
