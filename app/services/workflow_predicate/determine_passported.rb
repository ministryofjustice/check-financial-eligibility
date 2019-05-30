module WorkflowPredicate
  class DeterminePassported < BaseWorkflowService
    def call
      @particulars.request.applicant.receives_qualifying_benefit
    end
  end
end
