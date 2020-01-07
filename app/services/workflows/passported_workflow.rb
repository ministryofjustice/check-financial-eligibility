module Workflows
  class PassportedWorkflow < BaseWorkflowService
    def call
      collate_capitals
      Assessors::CapitalAssessor.call(assessment)
    end

    private

    def collate_capitals
      data = Collators::CapitalCollator.call(assessment)
      capital_summary.update!(data)
    end
  end
end
