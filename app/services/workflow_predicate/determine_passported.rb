module WorkflowPredicate
  class DeterminePassported < BaseWorkflowService
    def call
      applicant.receives_qualifying_benefit
    end
  end
end
