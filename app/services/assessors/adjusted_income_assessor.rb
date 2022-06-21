module Assessors
  class AdjustedIncomeAssessor < BaseWorkflowService
    delegate :adjusted_income, :crime_eligibility, :total_gross_income, to: :gross_income_summary
    delegate :dependants, to: :assessment

    def call
      ActiveRecord::Base.transaction do
        crime_eligibility.update!(assessment_result: assessment_result(crime_eligibility))
      end
    end

  private

    def assessment_result(elig)
      if adjusted_income <= elig.lower_threshold
        :eligible
      elsif adjusted_income <= elig.upper_threshold
        :full_means_test_required
      else
        :ineligible
      end
    end

    def adjusted_income
      if dependants.empty?
        total_gross_income
      else
        total_gross_income / overall_weighting
      end
    end

    def overall_weighting
      dependants_adjusted_ages = dependants.map(&:age_at_submission).map { |age| age + 1 }
      Threshold.value_for(:crime_adjusted_income_weightings)[:applicant] + dependants_adjusted_ages.map { |age| weighting(age) }.reduce(:+)
    end

    def weighting(age_at_submission)
      weightings = Threshold.value_for(:crime_adjusted_income_weightings)[:dependants]

      weightings.select { |key, _value| age_at_submission >= key[0] && age_at_submission <= key[1] }.values.first
    end
  end
end
