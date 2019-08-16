module WorkflowService
  class Passported < BaseWorkflowService
    def call
      return true if applicant.receives_qualifying_benefit?

      raise 'Not yet implemented: Check Financial Eligibility cannot yet handle non-passported applicants'
    end
  end
end
