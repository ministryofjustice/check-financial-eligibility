module Assessors
  class AssessmentCrimeAssessor < BaseWorkflowService
    class CrimeAssessmentError < StandardError; end

    def call
      assessment.crime_eligibility.update!(assessment_result: result)
    end

  private

    def result
      adjusted_income_assessment
    end

    def adjusted_income_assessment
      raise CrimeAssessmentError, "Assessment not complete: Adjusted Income assessment still pending" if adjusted_income_result == "pending"

      @adjusted_income_result
    end

    def adjusted_income_result
      @adjusted_income_result ||= assessment.gross_income_summary.crime_eligibility.assessment_result
    end
  end
end
