# WorkingDayCalculator
#
# This class is used to determine whether two dates are  a set number of days apart, allowing for bank holidays etc.
# It is called consecutively by RegularPeriodCalculator iterating through an array of payment dates.
#
# It is initialised with the expected period between payment dates (either 7, 14, or 28).  In this explanation, we will assume 7, but
# it will work equally well with 14 or 28.
#
# RegularPeriodCalculator then iterates through it's array of dates and calls #update on this class with:
#  - previous_payment_date
#  - current_payment_date
#  - iteration_count
#
# If the two dates are 7 days apart - all is well
# if dates are not:
#   * The expected_current_date is 7 days after the previous_payment_date
#   * If the expected_current_date date is a holiday
#     then current_payment_date can be the previous working day before, or the next working day after the expected_current_date
#
# In the case where the iteration_count is 1, the previous_payment_date will be have been the first in the array of dates, and may have been
# paid early because of a bank holiday, so we have to use different logic.
#   - We calculate the expected_previous_date as 7 days before the current_payment_date
#   - if expected_previous_date is a holiday,
#      - Then the previous_payment date can be either the last working day before the holiday or the next working day after the holiday.
#
# This class also needs to regular_payment_date would have been had there been no holidays, so that the RegularPeriodAnalyser can supply
# it as the previous date for the next iteration.
#
# - In normal_cases, the normalized_payment_date would be the current_payment_date
# - In cases where the current_payment_date was advanced or delayed because of a holiday, it will be 7 days after the previous_dates.
# - In cases where the very first date was a holiday, it will be the current_payment date
#

module Utilities
  class WorkingDayCalculator
    attr_reader :normalized_payment_date

    def initialize(period)
      @period = period
      @calendar = Business::Calendar.new(
        working_days: %w[mon tue wed thu fri],
        holidays: BankHoliday.dates
      )
    end

    def update(previous_payment_date, current_payment_date, iteration_count)
      @previous_payment_date = previous_payment_date
      @current_payment_date = current_payment_date
      @iteration_count = iteration_count
      @normalized_payment_date = @current_payment_date
    end

    def expected_period?
      expected_date = @previous_payment_date + @period.days
      return true if expected_date == @current_payment_date

      result = false
      if non_working_day?(expected_date)
        @normalized_payment_date = @previous_payment_date + @period.days
        result = true if current_payment_date_around_holiday?(expected_date)
      elsif first_iteration? && previous_payment_date_affected_by_holiday?
        result = true
      end
      result
    end

    private

    def current_payment_date_around_holiday?(expected_date)
      @current_payment_date == previous_working_day(expected_date) || @current_payment_date == next_working_day(expected_date)
    end

    def first_iteration?
      @iteration_count == 1
    end

    def previous_payment_date_affected_by_holiday?
      expected_previous_date = @current_payment_date - @period.days
      return false if working_day?(expected_previous_date)

      return true if previous_working_day(expected_previous_date) == @previous_payment_date
      return true if next_working_day(expected_previous_date) == @previous_payment_date

      false
    end

    def working_day?(date)
      @calendar.business_day?(date)
    end

    def non_working_day?(expected_date)
      !working_day?(expected_date)
    end

    def previous_working_day(expected_date)
      @calendar.roll_backward(expected_date)
    end

    def next_working_day(expected_date)
      @calendar.roll_forward(expected_date)
    end
  end
end
