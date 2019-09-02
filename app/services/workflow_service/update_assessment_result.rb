module WorkflowService
  class UpdateAssessmentResult < BaseWorkflowService
    # for now, only passported applicants are being processed, which means
    # there is only a capital assessment done and no income assessment, do
    # this just copies over the result
    def call
      assessment.assessment_result = translate_capital_summary_result
      assessment.save!
    end

    private

    def translate_capital_summary_result
      case capital_summary.capital_assessment_result
      when 'contribution_required'
        'capital_contribution_required'
      else
        capital_summary.capital_assessment_result
      end
    end
  end
end
