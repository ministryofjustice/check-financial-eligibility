module Calculators
  class MultipleEmploymentsCalculator
    def self.call(assessment:, employments:)
      new(assessment:, employments:).call
    end

    def initialize(assessment:, employments:)
      @employments = employments
      @assessment = assessment
    end

    def call
      EmploymentIncomeSubtotals.new(
        gross_employment_income: gross_income_values.fetch(:gross_employment_income),
        benefits_in_kind: gross_income_values.fetch(:benefits_in_kind),
        employment_income_deductions: disposable_income_values.fetch(:employment_income_deductions),
        tax: disposable_income_values.fetch(:tax),
        national_insurance: disposable_income_values.fetch(:national_insurance),
        fixed_employment_allowance: disposable_income_values.fetch(:fixed_employment_allowance),
      ).freeze
    end

  private

    def gross_income_values
      {
        gross_employment_income: 0.0,
        benefits_in_kind: 0.0,
      }
    end

    def disposable_income_values
      {
        employment_income_deductions: 0.0,
        tax: 0.0,
        national_insurance: 0.0,
        fixed_employment_allowance: -Threshold.value_for(:fixed_employment_allowance, at: @assessment.submission_date),
      }
    end
  end
end
