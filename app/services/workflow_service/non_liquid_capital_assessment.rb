module WorkflowService
  class NonLiquidCapitalAssessment
    def initialize(assessment_id)
      @assessment = Assessment.find assessment_id
    end

    def call
      total_value = 0.0
      @assessment.non_liquid_assets.each do |item|
        total_value += item.value
      end
      total_value.round(2)
    end
  end
end
