module Collators
  class GrossIncomeCollator < BaseWorkflowService
    def call # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      gross_income_summary.update!(
        upper_threshold: upper_threshold,
        monthly_other_income: categorised_income[:total],
        monthly_state_benefits: monthly_state_benefits,
        monthly_student_loan: monthly_student_loan,
        friends_or_family: categorised_income[:friends_or_family],
        maintenance_in: categorised_income[:maintenance_in],
        property_or_lodger: categorised_income[:property_or_lodger],
        student_loan: categorised_income[:student_loan],
        pension: categorised_income[:pension],
        total_gross_income: total_gross_income,
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

    def monthly_state_benefits
      @monthly_state_benefits ||= Calculators::StateBenefitsCalculator.call(assessment)
    end

    def monthly_student_loan
      @monthly_student_loan ||= calculate_monthly_student_loan
    end

    def calculate_monthly_student_loan
      return 0.0 if categorised_income.key?(:student_loan)

      if gross_income_summary.irregular_income_payments.exists?
        total = 0
        gross_income_summary.irregular_income_payments.each do |payment|
          total += (payment.amount / 12)
        end
        total
      else
        0.0
      end
    end

    def categorised_income
      @categorised_income ||= categorise_income
    end

    def categorise_income
      result = Hash.new(0.0)
      gross_income_summary.other_income_sources.each do |source|
        monthly_income = source.calculate_monthly_income!
        result[source.name.to_sym] = monthly_income
        result[:total] += monthly_income
      end
      result
    end

    def total_gross_income
      categorised_income[:total] + monthly_state_benefits + monthly_student_loan
    end
  end
end
