module WorkflowPredicate
  class BelowLowerCapitalThresholdPredicate < LegacyBaseWorkflowService
    def call
      raise 'Disposable Capital Assessment has not been calculated' if response_capital.disposable_capital_assessment.nil?

      response_capital.disposable_capital_assessment < response_capital.total_capital_lower_threshold
    end
  end
end
