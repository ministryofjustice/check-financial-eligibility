module Assessors
  class CapitalAssessor < BaseWorkflowService
    delegate :assessed_capital, to: :capital_summary

    def call
      capital_summary.eligibilities.each(&:update_assessment_result!)
      summary_result
    end

    private

    def summary_result
      Utilities::ResultSummarizer.call(capital_summary.eligibilities.map(&:assessment_result))
    end
  end
end
