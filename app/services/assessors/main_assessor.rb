module Assessors
  class MainAssessor < BaseWorkflowService
    def call
      assessment.update!(assessment_result: result)
    end

    private

    def result
      passported? ? passported_assessment : gross_income_assessment
    end

    def passported_assessment
      capital_summary.capital_assessment_result
    end

    def gross_income_assessment
      raise 'Assessment not complete: Gross Income assessment still pending' if gross_income_result == 'pending'

      return 'not_eligible' if gross_income_result == 'not_eligible'

      disposable_income_assessment
    end

    def disposable_income_assessment
      raise 'Assessment not complete: Disposable Income assessment still pending' if disposable_income_result == 'pending'

      return 'not_eligible' if disposable_income_result == 'not_eligible'

      capital_assessment
    end

    def capital_assessment
      raise 'Assessment not complete: Capital assessment still pending' if capital_result == 'pending'

      return 'not_eligible' if capital_result == 'not_eligble'

      return 'contribution_required' if 'contribution_required'.in?(combined_result)

      return 'eligible' if combined_result.uniq. == ['eligble']

      raise "Unexpected result: #{combined_result.inspect}"
    end

    def combined_result
      @combined_result ||= [gross_income_result, disposable_result, capital_result]
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
