module Assessors
  class MainAssessor < BaseWorkflowService

    class AssessmentError < StandardError; end

    def call
      assessment.update!(assessment_result: result)
    end

    private

    def result
      passported? ? passported_assessment : gross_income_assessment
    end

    def passported_assessment
      raise AssessmentError, 'Assessment not complete: Capital assessment still pending' if capital_summary.assessment_result == 'pending'
      raise AssessmentError, 'Invalid assessment status: for passported applicant' if disposable_income_summary && disposable_income_summary.assessment_result != 'pending'
      raise AssessmentError, 'Invalid assessment status: for passported applicant' if gross_income_summary && gross_income_summary.assessment_result != 'pending'

      capital_summary.assessment_result
    end

    def passported?
      applicant.receives_qualifying_benefit?
    end

    def gross_income_assessment
      raise AssessmentError, 'Assessment not complete: Gross Income assessment still pending' if gross_income_result == 'pending'

      return 'not_eligible' if gross_income_result == 'not_eligible'

      disposable_income_assessment
    end

    def disposable_income_assessment
      raise AssessmentError, 'Assessment not complete: Disposable Income assessment still pending' if disposable_income_result == 'pending'

      return 'not_eligible' if disposable_income_result == 'not_eligible'

      capital_assessment
    end

    def capital_assessment
      raise AssessmentError, 'Assessment not complete: Capital assessment still pending' if capital_result == 'pending'

      return 'not_eligible' if capital_result == 'not_eligible'

      return 'contribution_required' if 'contribution_required'.in?(combined_result)

      return 'eligible' if combined_result.uniq. == ['eligible']

      raise "Unexpected result: #{combined_result.inspect}"
    end

    def combined_result
      @combined_result ||= [gross_income_result, disposable_income_result, capital_result]
    end

    def gross_income_result
      gross_income_summary.assessment_result
    end

    def disposable_income_result
      disposable_income_summary.assessment_result
    end

    def capital_result
      capital_summary.assessment_result
    end
  end
end
