module Assessors
  class AssessmentProceedingTypeAssessor < BaseWorkflowService
    # this class examines the assessment results on capital, gross_income and
    # disposable income _eligibility records for the specified proceeding type code
    # and updates the corresponding assessment_eligibility records with an overall
    # result for that proceeding type
    #
    class AssessmentError < StandardError; end

    def initialize(assessment, proceeding_type_code)
      # @assessment = assessment
      super(assessment)
      @proceeding_type_code = proceeding_type_code
    end

    def call
      assessment_eligibility.update!(assessment_result: result)
    end

  private

    def result
      passported? ? passported_assessment : gross_income_assessment
    end

    def passported?
      applicant.receives_qualifying_benefit?
    end

    def passported_assessment
      raise AssessmentError, 'Assessment not complete: Capital assessment still pending' if capital_result == 'pending'
      raise AssessmentError, 'Invalid assessment status: for passported applicant' if disposable_income_summary && disposable_income_result != 'pending'
      raise AssessmentError, 'Invalid assessment status: for passported applicant' if gross_income_summary && gross_income_result != 'pending'

      capital_result
    end

    def gross_income_assessment
      raise AssessmentError, 'Assessment not complete: Gross Income assessment still pending' if gross_income_result == 'pending'

      return 'ineligible' if gross_income_result == 'ineligible'

      disposble_income_assessment
    end

    def disposble_income_assessment
      raise AssessmentError, 'Assessment not complete: Disposable Income assessment still pending' if disposable_income_result == 'pending'

      return disposable_income_result if disposable_income_result == 'ineligible'

      capital_assessment
    end

    def capital_assessment
      raise AssessmentError, 'Assessment not complete: Capital assessment still pending' if capital_result == 'pending'

      return 'ineligible' if capital_result == 'ineligible'

      return 'contribution_required' if 'contribution_required'.in?(combined_result)

      'eligible'
    end

    def assessment_eligibility
      @assessment_eligibility ||= assessment.eligibilities.find_by(proceeding_type_code: @proceeding_type_code)
    end

    def capital_eligibility
      @capital_eligibility ||= assessment.capital_summary.eligibilities.find_by(proceeding_type_code: @proceeding_type_code)
    end

    def gross_income_eligibility
      @gross_income_eligibility ||= assessment.gross_income_summary.eligibilities.find_by(proceeding_type_code: @proceeding_type_code)
    end

    def disposable_income_eligibility
      @disposable_income_eligibility ||= assessment.disposable_income_summary.eligibilities.find_by(proceeding_type_code: @proceeding_type_code)
    end

    def combined_result
      [gross_income_result, disposable_income_result, capital_result]
    end

    def gross_income_result
      gross_income_eligibility.assessment_result
    end

    def disposable_income_result
      disposable_income_eligibility.assessment_result
    end

    def capital_result
      capital_eligibility.assessment_result
    end
  end
end
