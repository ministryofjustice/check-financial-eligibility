module WorkflowPredicate
  class DetermineSelfEmployed < BaseWorkflowService
    def result_for(_particulars)
      true
    end
  end
end
