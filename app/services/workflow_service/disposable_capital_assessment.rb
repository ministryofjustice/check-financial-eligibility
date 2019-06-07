module WorkflowService
  class DisposableCapitalAssessment < BaseWorkflowService
    def call # rubocop:disable Metrics/AbcSize
      response_capital.liquid_capital_assessment = calculate_liquid_capital
      response_capital.property = calculate_property
      response_capital.vehicles = calculate_vehicles
      response_capital.non_liquid_capital_assessment = calculate_non_liquid_capital
      response_capital.single_capital_assessment = sum_assessed_values(response_capital)
      response_capital.pensioner_disregard = PensionerCapitalDisregard.new(@particulars).value
      response_capital.disposable_capital_assessment = response_capital.single_capital_assessment - response_capital.pensioner_disregard
      response_capital.total_capital_lower_threshold = Threshold.value_for(:capital_lower, at: @submission_date)
      response_capital.total_capital_upper_threshold = Threshold.value_for(:capital_upper, at: @submission_date)
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
      (capital.liquid_capital_assessment +
        capital.property.main_home.assessed_capital_value +
        capital.property.additional_properties.sum(&:assessed_capital_value) +
        capital.vehicles.sum(&:assessed_value) +
        capital.non_liquid_capital_assessment).round(2)
    end
  end
end
