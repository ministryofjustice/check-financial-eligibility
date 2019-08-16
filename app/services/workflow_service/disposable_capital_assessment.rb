module WorkflowService
  class DisposableCapitalAssessment < BaseWorkflowService
    def call
      calculate_capital_totals
      sum_capital_totals
      apply_pensioner_disregard
      apply_thresholds
      capital_summary.summarised!
      capital_summary.save!
      true
    end

    private

    def calculate_capital_totals
      capital_summary.total_liquid = calculate_liquid_capital
      capital_summary.total_non_liquid = calculate_non_liquid_capital
      capital_summary.total_vehicle = calculate_vehicles
      capital_summary.total_mortgage_allowance = Threshold.value_for(:property_maximum_mortgage_allowance, at: @submission_date)
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

    def sum_capital_totals
      capital_summary.total_capital = capital_summary.total_liquid +
                                      capital_summary.total_non_liquid +
                                      capital_summary.total_vehicle +
                                      capital_summary.total_property
    end

    def apply_pensioner_disregard
      capital_summary.pensioner_capital_disregard = PensionerCapitalDisregard.new(assessment).value
      capital_summary.assessed_capital = capital_summary.total_capital - capital_summary.pensioner_capital_disregard
    end

    def apply_thresholds
      capital_summary.lower_threshold = Threshold.value_for(:capital_lower, at: @submission_date)
      capital_summary.upper_threshold = Threshold.value_for(:capital_upper, at: @submission_date)
    end
  end
end
