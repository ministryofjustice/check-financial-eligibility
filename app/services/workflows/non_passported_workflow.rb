module Workflows
  class NonPassportedWorkflow < BaseWorkflowService
    def call
      return SelfEmployedWorkflow.call(assessment) if applicant.self_employed?

      collate_and_assess_gross_income

      disposable_income_assessment if gross_income_summary.eligible?
    end

    private

    def collate_and_assess_gross_income
      Collators::GrossIncomeCollator.call(assessment)
      Assessors::GrossIncomeAssessor.call(assessment)
    end

    def disposable_income_assessment
      Collators::OutgoingsCollator.call(assessment)
      Assessors::DisposableIncomeAssessor.call(assessment)
    end
  end
end
