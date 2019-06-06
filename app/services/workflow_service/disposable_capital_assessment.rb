module WorkflowService
  class DisposableCapitalAssessment < BaseWorkflowService
    def call
      response.details.capital.liquid_capital_assessment = calculate_liquid_capital
      response.details.capital.property = calculate_property
      response.details.capital.vehicles = calculate_vehicles
      true
    end

    private

    def calculate_liquid_capital
      LiquidCapitalAssessment.new(applicant_capital.liquid_capital).call
    end

    def calculate_property
      PropertyAssessment.new(applicant_capital.property, @submission_date).call
    end

    def calculate_vehicles
      VehicleAssessment.new(applicant_capital.vehicles, @submission_date).call
    end
  end
end
