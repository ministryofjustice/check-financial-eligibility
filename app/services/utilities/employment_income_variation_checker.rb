module Utilities
  class EmploymentIncomeVariationChecker
    def initialize(employment_payments)
      @employment_payments = employment_payments
    end

    def below_threshold?(submission_date)
      variance < Threshold.value_for(:employment_income_variance, at: submission_date)
    end

  private

    def variance
      amounts = @employment_payments.map(&:gross_income_monthly_equiv)
      (amounts.max - amounts.min)
    end
  end
end
