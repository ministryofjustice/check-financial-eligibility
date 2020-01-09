module Assessors
  class GrossIncomeAssessor < BaseWorkflowService
    def call
      raise 'Gross income not summarised' if gross_income_summary.assessment_result == 'pending'

      gross_income_summary.update!(assessment_result: assessment_result)
    end

    private

    def assessment_result
      income < threshold ? 'eligible' : 'not_eligible'
    end

    def income
      gross_income_summary.total_gross_income
    end

    def threshold
      gross_income_summary.upper_threshold
    end
  end
end
