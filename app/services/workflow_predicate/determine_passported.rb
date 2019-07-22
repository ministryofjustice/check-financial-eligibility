module WorkflowPredicate
  class DeterminePassported < BaseWorkflowService
    def call
      @assessment.applicant.receives_qualifying_benefit
    end
  end
end
