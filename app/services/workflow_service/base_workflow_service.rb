class WorkflowService::BaseWorkflowService
  def initialize(particulars)
    @particulars = particulars
  end

  def call
    # define in derived class
  end
end
