module WorkflowService
  class NotSelfEmployed < BaseWorkflowService
    def call
      raise 'Not Implemented: Check Financial Benefit has not yet been implemented for non-passported applicants'
    end
  end
end
