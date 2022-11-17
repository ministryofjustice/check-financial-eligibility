module Calculators
  class EmploymentIncomeCalculator
    def self.call(submission_date:, employment:, disposable_income_summary:, gross_income_summary:)
      new(submission_date:, employment:, disposable_income_summary:, gross_income_summary:).call
    end

    def initialize(submission_date:, employment:, disposable_income_summary:, gross_income_summary:)
      @submission_date = submission_date
      @employment = employment
      @disposable_income_summary = disposable_income_summary
      @gross_income_summary = gross_income_summary
    end

    def call
      process_single_employment
    end

  private

    def process_single_employment
      @employment&.calculate!

      @gross_income_summary.update!(gross_employment_income:,
                                    benefits_in_kind: monthly_benefits_in_kind)
      @disposable_income_summary.update!(employment_income_deductions: deductions,
                                         fixed_employment_allowance: allowance,
                                         tax: taxes,
                                         national_insurance: ni_contributions)
    end

    def gross_employment_income
      monthly_incomes + monthly_benefits_in_kind
    end

    def monthly_incomes
      @employment&.monthly_gross_income || 0.0
    end

    def monthly_benefits_in_kind
      @employment&.monthly_benefits_in_kind || 0.0
    end

    def deductions
      taxes + ni_contributions
    end

    def taxes
      @employment&.monthly_tax || 0.0
    end

    def ni_contributions
      @employment&.monthly_national_insurance || 0.0
    end

    def allowance
      @employment.present? ? fixed_employment_allowance : 0.0
    end

    def fixed_employment_allowance
      -Threshold.value_for(:fixed_employment_allowance, at: @submission_date)
    end
  end
end
