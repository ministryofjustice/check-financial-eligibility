module Assessors
  class DisposableIncomeAssessor < BaseWorkflowService
    delegate :total_disposable_income,
             :lower_threshold,
             :upper_threshold, to: :disposable_income_summary

    def call
      disposable_income_summary.update!(
        assessment_result: assessment_result,
        income_contribution: income_contribution
      )
    end

    private

    def assessment_result
      @assessment_result ||= assess
    end

    def income_contribution
      assessment_result == 'contribution_required' ? calculate_contribution : 0.0
    end

    def calculate_contribution
      Calculators::IncomeContributionCalculator.call(total_disposable_income)
    end

    def assess
      if total_disposable_income <= lower_threshold
        'eligible'
      elsif total_disposable_income < upper_threshold
        'contribution_required'
      else
        'ineligible'
      end
    end
  end
end
