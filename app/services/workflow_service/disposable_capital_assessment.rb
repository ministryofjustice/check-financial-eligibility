module WorkflowService
  class DisposableCapitalAssessment < BaseWorkflowService
    def call # rubocop:disable Metrics/AbcSize
      capital = response.details.capital
      capital.liquid_capital_assessment = calculate_liquid_capital
      capital.property = calculate_property
      capital.vehicles = calculate_vehicles
      capital.non_liquid_capital_assessment = calculate_non_liquid_capital
      capital.single_capital_assessment = sum_assessed_values(capital)
      capital.pensioner_disregard = PensionerCapitalDisregard.new(@particulars).value
      capital.disposable_capital_assessment = capital.single_capital_assessment - capital.pensioner_disregard
      true
    end

    private

    def calculate_liquid_capital
      LiquidCapitalAssessment.new(applicant_capital.liquid_capital).call
    end

    def calculate_non_liquid_capital
      NonLiquidCapitalAssessment.new(applicant_capital.non_liquid_capital).call
    end

    def calculate_property
      PropertyAssessment.new(applicant_capital.property, @submission_date).call
    end

    def calculate_vehicles
      VehicleAssessment.new(applicant_capital.vehicles, @submission_date).call
    end

    def sum_assessed_values(capital)
      capital.liquid_capital_assessment +
        capital.property.main_home.assessed_capital_value +
        capital.property.additional_properties.sum(&:asssessed_capital_value) +
        capital.vehicles.sum(&:assessed_value) +
        capital.non_liquid_capital_assessment
    end
  end
end
