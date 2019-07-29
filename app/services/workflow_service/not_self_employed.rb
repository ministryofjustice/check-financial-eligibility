module WorkflowService
  class NotSelfEmployed < LegacyBaseWorkflowService
    def call
      true
    end
  end
end
