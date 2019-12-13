module Workflows
  class PassportedWorkflow < BaseWorkflowService

    def call
      collate_capitals
      Assessors::CapitalAssessor.call(assessment)
      mark_income_as_not_applicable
    end

    private

    def collate_capitals
      data = Collators::CapitalCollator.call(assessment)
      capital_summary.update!(data)
    end

    def mark_income_as_not_applicable
      gross_income_summary.not_applicable!
    end

  end
end
