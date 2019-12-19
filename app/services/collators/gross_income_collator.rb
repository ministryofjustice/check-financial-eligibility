module Collators
  class GrossIncomeCollator < BaseWorkflowService
    def call
      gross_income_summary.update!(
        upper_threshold: upper_threshold,
        monthly_other_income: monthly_other_income,
        assessment_result: 'summarised'
      )
    end

    private

    def upper_threshold
      return infinite_threshold if assessment.matter_proceeding_type == 'domestic_abuse' && assessment.applicant.involvement_type == 'applicant'

      Threshold.value_for(:gross_income_upper, at: assessment.submission_date) + dependant_increase
    end

    def infinite_threshold
      @infinite_threshold ||= Threshold.value_for(:infinite_gross_income_upper, at: assessment.submission_date)
    end

    def dependant_increase_starts_after
      @dependant_increase_starts_after ||= Threshold.value_for(:dependant_increase_starts_after, at: assessment.submission_date)
    end

    def dependant_step
      @dependant_step ||= Threshold.value_for(:dependant_step, at: assessment.submission_date)
    end

    def number_of_child_dependants
      assessment.dependants.where(relationship: 'child_relative').count
    end

    def dependant_increase
      return 0 unless number_of_child_dependants > dependant_increase_starts_after

      (number_of_child_dependants - dependant_increase_starts_after) * dependant_step
    end

    def monthly_other_income
      total = 0.0
      gross_income_summary.other_income_sources.each do |source|
        total += source.calculate_monthly_income!
      end
      total
    end
  end
end
