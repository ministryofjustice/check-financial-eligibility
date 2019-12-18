module Assessors
  class GrossIncomeAssessor < BaseWorkflowService
    def call
      raise "Gross income not summarised" if gross_income_summary.assessment_result == 'pending'

      raise "Gross income summary marked as not applicable" if gross_income_summary.assessment_result == 'not_applicable'

      gross_income_summary.update!(assessment_result: assessment_result)
    end

    private

    def assessment_result
      monthly_other_income
    end
  end
end
