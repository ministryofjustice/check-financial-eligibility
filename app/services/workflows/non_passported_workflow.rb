module Workflows
  class NonPassportedWorkflow < BaseWorkflowService
    def call
      return SelfEmployedWorkflow.call(assessment) if applicant.self_employed?

      collate_and_assess_gross_income
      disposable_income_assessment if gross_income_summary.eligible?

      return if disposable_income_summary.ineligible?
      collate_and_assess_capital
      # collate_and_assess_capital if disposable_income_summary.eligible? || disposable_income_summary.contribution_required?

      # collate_and_assess_capital if disposable_income_summary.summarized_assessment_result.in?([:eligible, :contribution_required, :partially_eligible])
    end

    private

    def collate_and_assess_gross_income
      Collators::GrossIncomeCollator.call(assessment)
      Assessors::GrossIncomeAssessor.call(assessment)
    end

    def collate_outgoings
      Collators::OutgoingsCollator.call(assessment)
    end

    def disposable_income_assessment
      collate_outgoings
      Collators::DisposableIncomeCollator.call(assessment)
      Assessors::DisposableIncomeAssessor.call(assessment)
    end

    def collate_and_assess_capital
      data = Collators::CapitalCollator.call(assessment)
      capital_summary.update!(data)
      Assessors::CapitalAssessor.call(assessment)
    end
  end
end
