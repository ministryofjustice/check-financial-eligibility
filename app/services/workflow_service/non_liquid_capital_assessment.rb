module WorkflowService
  class NonLiquidCapitalAssessment
    def initialize(request)
      @request = request
    end

    def call
      total_value = 0.0
      @request&.each do |item|
        total_value += item.value
      end
      total_value.round(2)
    end
  end
end
