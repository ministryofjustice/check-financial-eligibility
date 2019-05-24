module WorkflowService
  class NotSelfEmployed < BaseWorkflowService
    def result_for
      true
    end
  end
end
