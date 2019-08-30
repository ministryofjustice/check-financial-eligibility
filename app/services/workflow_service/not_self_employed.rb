module WorkflowService
  class NotSelfEmployed < BaseWorkflowService
    def call
      true
    end
  end
end
