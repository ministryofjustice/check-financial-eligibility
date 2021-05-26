module Assessors
  class GrossIncomeAssessor < BaseWorkflowService
    def call
      gross_income_summary.eligibilities.map(&:update_assessment_result!)
    end
  end
end
