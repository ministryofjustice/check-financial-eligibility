# rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
class PaymentPeriodAnalyser
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
    return false if dates.size > 4
    return false if days_between_dates.median < 28.5
    return false if dates.size == 4 && date_slope < -1.6
    return false if date_slope < -2
    return false if days_between_dates.range > 9

    true
  end

  def weekly?
    return true if dates.size > 8
    return false if around_28(days_between_dates.median) || around_28(days_between_dates.range)
    return true if days_between_dates.median > 19 && days_between_dates.range > 19 && days.range > 10

    false
  end

  def two_weekly?
    return false if dates.size > 8
    return true if around_14(days_between_dates.median) && days_between_dates.range < 6
    return true if around_28(days_between_dates.median) && around_28(days_between_dates.range)
    return true if around_7_or_14(days_between_dates.median) && around_14_or_21_or_28(days_between_dates.range)
    return true if around_14_or_21(days_between_dates.median) && around_7_or_14(days_between_dates.range)

    false
  end

  def four_weekly?
    return false if monthly?
    return false if dates.size > 5
    return true if around_28(days_between_dates.median) && days_between_dates.range < 6
    return true if days_between_dates.median > 30 && around_28(days_between_dates.range)

    false
  end

  def around_28(number)
    number.between?(26, 30)
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

  def around_14_or_21_or_28(number)
    around_14(number) || around_21(number) || around_28(number)
  end

  # Weekly sequences tend to have day numbers that reduce through the sequence
  # So the greater the negative slope the less likely the data is monthly.
  def date_slope
    data = dates.map(&:day).each_with_index.each_with_object({}) { |(n, i), h| h[i] = n }
    size = dates.size

    sum_x = 0
    sum_y = 0
    sum_xx = 0
    sum_xy = 0

    # calculate the sums
    data.each do |x, y|
      sum_xy += x * y
      sum_xx += x * x
      sum_x  += x
      sum_y  += y
    end

    1.0 * ((size * sum_xy) - (sum_x * sum_y)) / ((size * sum_xx) - (sum_x * sum_x))
  end

  def time_series_calculator
    @time_series_calculator ||= TimeSeriesCalculator.new(data)
  end
  delegate :average_days_between_dates, :deviation_between_dates, :days_between_dates, :dates, :days,
           to: :time_series_calculator
end
# rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
