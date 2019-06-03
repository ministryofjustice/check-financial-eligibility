module WorkflowService
  class DisposableCapitalAssessment < BaseWorkflowService
    def call
      response.details.capital.liquid_capital_assessment = calculate_liquid_capital
      # TODO: refactor this to pass in just the bit of interest and receive back just the bit of interest

      PropertyAssessment.new(@particulars).call
      VehicleAssessment.new(@particulars).call
      true
    end

    private

    def calculate_liquid_capital
      LiquidCapitalAssessment.new(applicant_capital.liquid_capital).call
    end
  end
end
