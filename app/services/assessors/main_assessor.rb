module Assessors
  class MainAssessor < BaseWorkflowService
    delegate :eligibilities, :crime_eligibility, to: :assessment

    def call
      if assessment.criminal?
        AssessmentCrimeAssessor.call(assessment)
        assessment.update!(assessment_result: assessment.crime_eligibility.assessment_result)
      else
        assessment.proceeding_type_codes.each { |ptc| AssessmentProceedingTypeAssessor.call(assessment, ptc) }
        assessment.update!(assessment_result: summarized_result)
      end
    end

  private

    def summarized_result
      Utilities::ResultSummarizer.call(eligibilities.map(&:assessment_result))
    end
  end
end
