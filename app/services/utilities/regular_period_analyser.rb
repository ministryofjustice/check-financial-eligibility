module Utilities
  class RegularPeriodAnalyser
    EXPECTED_NUMBER_OF_DATES = {
      7 => [12, 13],
      14 => [6, 7],
      28 => [3, 4]
    }.freeze

    # Given a period (7, 14, 28) and an array of dates, returns true if those dates, after taking into account bank holidays,
    # are every 7, 14, days, otherwise false
    #
    def self.call(period, dates)
      new(period, dates).call
    end

    def initialize(period, dates)
      @period = period
      @dates = dates
      @calculator = WorkingDayCalculator.new(@period)
    end

    def call
      return false unless expected_number_of_dates?

      return false unless regular_intervals?

      true
    end

  private

    def expected_number_of_dates?
      expected_sizes = EXPECTED_NUMBER_OF_DATES[@period]

      return false unless expected_sizes.include? @dates.size

      true
    end

    def regular_intervals?
      previous_date = @dates.first
      @dates.each_with_index do |date, iteration_count|
        next if iteration_count.zero?

        @calculator.update(previous_date, date, iteration_count)
        return false unless @calculator.expected_period?

        previous_date = @calculator.normalized_payment_date
      end
      true
    end
  end
end
