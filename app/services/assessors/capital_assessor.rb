module Assessors
  class CapitalAssessor < BaseWorkflowService
    delegate :assessed_capital, :lower_threshold, to: :capital_summary

    def call
      capital_summary.update!(assessment_result: result)
    end

    private

    def result
      return :eligible if assessed_capital <= lower_threshold

      :contribution_required
    end
  end
end
