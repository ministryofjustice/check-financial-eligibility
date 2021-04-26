module Assessors
  class GrossIncomeAssessor < BaseWorkflowService
    def call
      raise 'Gross income not summarised' if gross_income_summary.summarized_assessment_result == 'pending'

      gross_income_summary.eligibilities.map(&:update_assessment_result!)
    end
  end
end
