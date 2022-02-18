module Utilities
  class EmploymentIncomeVariationChecker
    def self.call(employment)
      new(employment).call
    end

    def initialize(employment)
      @employment = employment
    end

    def call
      amounts = @employment.employment_payments.map(&:gross_income_monthly_equiv)
      (amounts.max - amounts.min)
    end
  end
end
