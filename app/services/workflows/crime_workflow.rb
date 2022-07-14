module Workflows
  class CrimeWorkflow < BaseWorkflowService
    def call
      collate_and_assess_gross_income
    end

  private

    def collate_and_assess_gross_income
      Collators::GrossIncomeCollator.call(assessment)
      Assessors::AdjustedIncomeAssessor.call(assessment)
    end
  end
end
