module Calculators
  class MonthlyIncomeConverter
    attr_reader :monthly_amount, :error_message

    def initialize(frequency, payments)
      @frequency = frequency
      @payments = payments
      @error = false
      @error_message = nil
      @monthly_amount = nil
    end

    def run
      raise 'Unrecognized frequency' unless @frequency.in?(CFEConstants::VALID_FREQUENCIES)

      @monthly_amount = __send__("process_#{@frequency}")
    end

    def error?
      run
      @error
    end

  private

    def process_monthly
      payment_average.round(2)
    end

    def process_four_weekly
      ((payment_average / 4) * 52 / 12).round(2)
    end

    def process_two_weekly
      ((payment_average / 2) * 52 / 12).round(2)
    end

    def process_weekly
      (payment_average * 52 / 12).round(2)
    end

    def process_unknown
      (@payments.sum.to_f / CFEConstants::NUMBER_OF_MONTHS_TO_AVERAGE).round(2)
    end

    def payment_average
      @payments.sum.to_f / @payments.size
    end
  end
end
