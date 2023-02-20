module Utilities
  class EmploymentIncomeMonthlyEquivalentCalculator
    def self.call(employment)
      new(employment).call
    end

    def initialize(employment)
      @employment = employment
    end

    def call
      period = PaymentPeriodAnalyser.new(dates).period_pattern
      if period == :unknown
        set_monthly_equivalents_from_unknown_period
      else
        set_monthly_equivalents_from_known_period(period)
      end
    end

  private

    def blunt_average(attribute)
      (@employment.employment_payments.sum(&attribute) / @employment.employment_payments.count).round(2)
    end

    def set_monthly_equivalents_from_known_period(period)
      @employment.employment_payments.each do |payment|
        payment.update(
          gross_income_monthly_equiv: Utilities::MonthlyAmountConverter.call(period, payment.gross_income),
          tax_monthly_equiv: Utilities::MonthlyAmountConverter.call(period, payment.tax),
          national_insurance_monthly_equiv: Utilities::MonthlyAmountConverter.call(period, payment.national_insurance),
        )
      end
    end

    def set_monthly_equivalents_from_unknown_period
      @employment.employment_payments.each do |payment|
        payment.update(
          gross_income_monthly_equiv: blunt_average(:gross_income),
          tax_monthly_equiv: blunt_average(:tax),
          national_insurance_monthly_equiv: blunt_average(:national_insurance),
        )
      end
    end

    def dates
      @employment.employment_payments.map(&:date)
    end
  end
end
