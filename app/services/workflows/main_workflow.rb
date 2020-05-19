module Workflows
  class MainWorkflow < BaseWorkflowService
    def call
      if applicant_passported?
        PassportedWorkflow.call(assessment)
      else
        NonPassportedWorkflow.call(assessment)
      end
      RemarkGenerators::Orchestrator.call(assessment)
      Assessors::MainAssessor.call(assessment)
    end

    private

    def applicant_passported?
      applicant.receives_qualifying_benefit?
    end
  end
end
