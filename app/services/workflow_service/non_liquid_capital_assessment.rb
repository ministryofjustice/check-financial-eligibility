module WorkflowService
  class NonLiquidCapitalAssessment < BaseWorkflowService
    def call
      total_value = 0.0
      non_liquid_assets.each do |item|
        total_value += item.value
      end
      total_value.round(2)
    end
  end
end
