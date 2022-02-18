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
      calc_method = determine_calc_method(period)
      update_payments(calc_method)
    end

  private

    def determine_calc_method(period)
      case period
      when :monthly
        :monthly_to_monthly
      when :four_weekly
        :four_weekly_to_monthly
      when :two_weekly
        :two_weekly_to_monthly
      when :weekly
        :weekly_to_monthly
      else
        raise ArgumentError, "unexpected period #{period}"
      end
    end

    def monthly_to_monthly(value)
      value
    end

    def four_weekly_to_monthly(value)
      (value / 4 * 52 / 12).round(2)
    end

    def two_weekly_to_monthly(value)
      (value / 2 * 52 / 12).round(2)
    end

    def weekly_to_monthly(value)
      (value * 52 / 12).round(2)
    end

    def update_payments(calc_method)
      @employment.employment_payments.each do |payment|
        payment.update(gross_income_monthly_equiv: __send__(calc_method, payment.gross_income))
      end
    end

    def dates
      @employment.employment_payments.map(&:date)
    end
  end
end
