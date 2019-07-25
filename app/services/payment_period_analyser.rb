# rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
class PaymentPeriodAnalyser
  SIZE_THRESHOLD_WEEKLY = 8 # Threshold above which data size could only match a weekly pattern
  SIZE_THRESHOLD_MONTHLY = 4 # Threshold above which data size cannot match a monthly pattern
  SIZE_THRESHOLD_FOUR_WEEKLY = 5 # Threshold above which data size cannot match a four weekly pattern

  MONTHLY_MEDIAN_LIMIT = 28.5 # Below this the median of the number of days between dates is too small for monthly pattern
  MONTHLY_RANGE_LIMIT = 9 # Monthly data is unlikely to have a large range of days between dates. So above this not monthly pattern

  MONTHLY_SLOPE_LIMIT = { upper: -1.6, lower: -2 }.freeze # Below these limits, slopes better match four weekly than monthly

  SMALL_VARIANCE = 6
  LARGE_VARIANCE = 10
  VERY_LARGE_VARIANCE = 19

  def self.pattern_for(data)
    new(data).period_pattern
  end

  attr_reader :data

  def initialize(data)
    @data = data
  end

  def period_pattern
    return :monthly if monthly?
    return :weekly if weekly?
    return :two_weekly if two_weekly?
    return :four_weekly if four_weekly?

    :unknown
  end

  def monthly?
    return false if dates.size > SIZE_THRESHOLD_MONTHLY
    return false if days_between_dates.median < MONTHLY_MEDIAN_LIMIT
    # At size threshold, data is more likely to be four weekly so can move slope limit so easier to match to four weekly
    return false if dates.size == SIZE_THRESHOLD_MONTHLY && date_slope < MONTHLY_SLOPE_LIMIT[:upper]
    return false if date_slope < MONTHLY_SLOPE_LIMIT[:lower]
    return false if days_between_dates.range > MONTHLY_RANGE_LIMIT

    true
  end

  def weekly?
    return true if dates.size > SIZE_THRESHOLD_WEEKLY
    return false if around_28(days_between_dates.median) || around_28(days_between_dates.range)
    return true if days_between_dates.median > VERY_LARGE_VARIANCE &&
                   days_between_dates.range > VERY_LARGE_VARIANCE &&
                   days.range > LARGE_VARIANCE

    false
  end

  def two_weekly?
    return false if dates.size > SIZE_THRESHOLD_WEEKLY
    return true if around_14(days_between_dates.median) && days_between_dates.range < SMALL_VARIANCE
    return true if around_28(days_between_dates.median) && around_28(days_between_dates.range)
    return true if around_7_or_14(days_between_dates.median) && around_14_or_21_or_28(days_between_dates.range)
    return true if around_14_or_21(days_between_dates.median) && around_7_or_14(days_between_dates.range)

    false
  end

  def four_weekly?
    return false if monthly?
    return false if dates.size > SIZE_THRESHOLD_FOUR_WEEKLY
    return true if around_28(days_between_dates.median) && days_between_dates.range < SMALL_VARIANCE
    return true if days_between_dates.median > MONTHLY_MEDIAN_LIMIT && around_28(days_between_dates.range)

    false
  end

  # Factors of 7 have a particular significance when analysing weekly sequences of data. Which means patterns
  # around the numbers 7, 14, 21, and 28 can be used to identify the likely sequence type.
  def around_28(number)
    number.between?(24, 30)
  end

  def around_21(number)
    number.between?(20, 22)
  end

  def around_14(number)
    number.between?(12, 16)
  end

  def around_7(number)
    number.between?(6, 8)
  end

  def around_14_or_21(number)
    around_14(number) || around_21(number)
  end

  def around_7_or_14(number)
    around_7(number) || around_14(number)
  end

  # :nocov:
  # Some combinations of test data lead to this check being skipped
  def around_14_or_21_or_28(number)
    around_14(number) || around_21(number) || around_28(number)
  end
  # :nocov:

  # Four weekly sequences tend to have day numbers that reduce through the sequence
  # So the greater the negative slope the less likely the data is monthly.
  def date_slope
    @date_slope ||= DateSlope.call(dates)
  end

  def time_series_calculator
    @time_series_calculator ||= TimeSeriesCalculator.new(data)
  end
  delegate :average_days_between_dates, :deviation_between_dates, :days_between_dates, :dates, :days,
           to: :time_series_calculator
end
# rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
