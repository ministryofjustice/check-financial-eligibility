module WorkflowPredicate
  class BelowLowerCapitalThresholdPredicate < BaseWorkflowService
    def call
      raise 'Disposable Capital Assessment has not been calculated' if capital_summary.pending?

      capital_summary.assessed_capital < capital_summary.lower_threshold
    end
  end
end
