module Calculators
  class EmploymentIncomeCalculator
    delegate :disposable_income_summary,
             :employments,
             :gross_income_summary,
             :submission_date,
             to: :assessment

    attr_reader :assessment

    def self.call(assessment)
      new(assessment).call
    end

    def initialize(assessment)
      @assessment = assessment
    end

    def call
      employments.map(&:calculate_monthly_amounts!)
      gross_income_summary.update!(gross_employment_income: gross_employment_income,
                                   benefits_in_kind: monthly_benefits_in_kind)
      disposable_income_summary.update!(employment_income_deductions: deductions,
                                        fixed_employment_allowance: allowance,
                                        tax: taxes,
                                        national_insurance: ni_contributions)
    end

    private

    def gross_employment_income
      monthly_incomes + monthly_benefits_in_kind
    end

    def monthly_incomes
      employments.sum(&:monthly_gross_income)
    end

    def monthly_benefits_in_kind
      @monthly_benefits_in_kind ||= employments.sum(&:monthly_benefits_in_kind)
    end

    def deductions
      taxes + ni_contributions
    end

    def taxes
      @taxes ||= employments.sum(&:monthly_tax)
    end

    def ni_contributions
      employments.sum(&:monthly_national_insurance)
    end

    def allowance
      employments.any? ? fixed_employment_allowance : 0.0
    end

    def fixed_employment_allowance
      Threshold.value_for(:fixed_employment_allowance, at: submission_date)
    end
  end
end
