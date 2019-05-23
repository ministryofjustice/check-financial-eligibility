module WorkflowPredicate
  class DeterminePassported
    def result(particulars)
      particulars.request.applicant.receives_qualifying_benefit
    end
  end
end
