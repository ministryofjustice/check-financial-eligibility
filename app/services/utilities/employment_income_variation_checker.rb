module Utilities
  class EmploymentIncomeVariationChecker
    def initialize(employment)
      @employment = employment
    end

    def below_threshold?
      variance < Threshold.value_for(:employment_income_variance, at: submission_date)
    end

  private

    def variance
      amounts = @employment.employment_payments.map(&:gross_income_monthly_equiv)
      (amounts.max - amounts.min)
    end

    def submission_date
      @employment.assessment.submission_date
    end
  end
end
