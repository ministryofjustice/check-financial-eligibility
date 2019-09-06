module WorkflowService
  class DisposableCapitalAssessment < BaseWorkflowService
    def call
      calculate_capital_totals
      capital_summary.sum_totals!
      capital_summary.assess_capital!
      capital_summary.summarised!
      capital_summary.save!
      true
    end

    private

    def calculate_capital_totals
      capital_summary.total_liquid = calculate_liquid_capital
      capital_summary.total_non_liquid = calculate_non_liquid_capital
      capital_summary.total_vehicle = calculate_vehicles
      capital_summary.total_mortgage_allowance = Threshold.value_for(:property_maximum_mortgage_allowance, at: submission_date)
      capital_summary.total_property = calculate_property
    end

    def calculate_liquid_capital
      LiquidCapitalAssessment.new(assessment).call
    end

    def calculate_non_liquid_capital
      NonLiquidCapitalAssessment.new(assessment).call
    end

    def calculate_property
      PropertyAssessment.new(assessment).call
    end

    def calculate_vehicles
      VehicleAssessment.new(assessment).call
    end
  end
end
