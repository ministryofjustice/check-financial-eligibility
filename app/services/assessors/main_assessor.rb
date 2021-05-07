module Assessors
  class MainAssessor < BaseWorkflowService
    delegate :eligibilities, to: :assessment

    def call
      assessment.proceeding_type_codes.each { |ptc| AssessmentProceedingTypeAssessor.call(assessment, ptc) }
      assessment.update!(assessment_result: summarized_result)
    end

    private

    def summarized_result
      Utilities::ResultSummarizer.call(eligibilities.map(&:assessment_result))
    end
  end
end
