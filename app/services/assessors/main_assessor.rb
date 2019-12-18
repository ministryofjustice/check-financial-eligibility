module Assessors
  class MainAssessor < BaseWorkflowService
    def call
      # for now, this will be just the capital_summary assessment result, but once non-passported
      # applicants are being processed, we need to take into account gross income summary and
      # disposable income summary results (these will be set to 'not_applicable' for passported
      # applicants)
      raise 'Capital assessment not complete' if capital_summary.capital_assessment_result == 'pending'

      assessment.assessment_result = capital_summary.capital_assessment_result
    end
  end
end
