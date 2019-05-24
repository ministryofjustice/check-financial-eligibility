module WorkflowPredicate
  class DeterminePassported < BaseWorkflowService
    def result_for
      @particulars.request.applicant.receives_qualifying_benefit
    end
  end
end
