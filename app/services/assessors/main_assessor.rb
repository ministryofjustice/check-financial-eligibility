module Assessors
  class MainAssessor < BaseWorkflowService
    delegate :eligibilities, to: :assessment

    def call
      proceeding_type_codes.each { |ptc| AssessmentProceedingTypeAssessor.call(assessment, ptc) }
      assessment.update!(assessment_result: summarized_result)
    end

  private

    def proceeding_type_codes
      assessment.version_5? ? assessment.proceeding_types.map(&:ccms_code) : assessment.proceeding_type_codes
    end

    def summarized_result
      Utilities::ResultSummarizer.call(eligibilities.map(&:assessment_result))
    end
  end
end
