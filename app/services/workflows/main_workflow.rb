module Workflows
  class MainWorkflow < BaseWorkflowService
    def call
      version_5_verification(assessment)
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

    def version_5_verification(assessment)
      return unless assessment.version_5?

      raise "Proceeding Types not created" unless assessment.proceeding_types.any?

      Utilities::ProceedingTypeThresholdPopulator.call(assessment)
      Creators::EligibilitiesCreator.call(assessment)
    end
  end
end
