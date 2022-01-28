module Utilities
  class CalendarMonthlyPeriodAnalyser
    VALID_NUMBER_OF_DATES = [3, 4].freeze

    def self.call(dates)
      new(dates).call
    end

    def initialize(dates)
      @dates = dates
      @calendar = Business::Calendar.new(
        working_days: %w[mon tue wed thu fri],
        holidays: BankHoliday.dates
      )
    end

    def call
      return false unless @dates.size.in?(VALID_NUMBER_OF_DATES)
      return true if all_same_day_of_month?
      return true if calendar_month_intervals?
      return true if first_date_before_bank_holiday?

      false
    end

  private

    def all_same_day_of_month?
      @dates.map(&:day).uniq.size == 1
    end

    # we've already established that it is not at calendar intervals even accounting
    # for holidays in the middle of the sequence.  Now we test to see if the first date
    # has been adjusted for a bank holiday
    def first_date_before_bank_holiday?
      actual_first_payment_date = @dates.first
      second_payment_date = @dates[1]
      expected_first_payment_date = second_payment_date - 1.month
      return true if @calendar.roll_forward(expected_first_payment_date) == actual_first_payment_date
      return true if @calendar.roll_backward(expected_first_payment_date) == actual_first_payment_date

      false
    end

    def calendar_month_intervals?
      result = true
      @dates.each_with_index do |date, iteration_count|
        next if iteration_count.zero?

        expected_date = first_payment_date + iteration_count.months
        next if date == expected_date

        next if end_of_feb_check_needed?(date, iteration_count)

        result = false unless bank_holiday_adjustment?(date, expected_date)
        break if result == false
      end
      result
    end

    def first_payment_date
      @first_payment_date ||= @dates.first
    end

    def end_of_feb_check_needed?(date, iteration_count)
      return unless first_payment_date.month.eql?(2) && first_payment_date.day > 27

      expected_date = date - iteration_count.months
      first_payment_date == expected_date
    end

    def bank_holiday_adjustment?(actual_date, expected_date)
      return false if @calendar.business_day?(expected_date)
      return true if actual_date == @calendar.roll_backward(expected_date)
      return true if actual_date == @calendar.roll_forward(expected_date)

      false
    end
  end
end
