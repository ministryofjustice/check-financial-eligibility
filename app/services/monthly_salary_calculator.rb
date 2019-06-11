class MonthlySalaryCalculator
  PeriodError = Class.new(StandardError)
  NORMAL_VARIANCE_THRESHOLD = 60

  def self.call(*args)
    new(*args).monthly_equivalent
  end

  attr_reader :time_series, :period_type

  # Time series is a hash with times as keys, and salaries as values
  def initialize(time_series:, period_type:)
    @time_series = time_series
    @period_type = period_type
  end

  def monthly_equivalent
    case period_type.to_sym
    when :weekly
      for_weekly
    when :two_weekly
      for_two_weekly
    when :four_weekly
      for_four_weekly
    when :monthly
      normalize_monthly
    else
      raise PeriodError, "Period type :#{period_type} not recognised. Use one of :weekly, :two_weekly, :four_weekly, :monthly"
    end
  end

  private

  def for_weekly
    weekly_to_monthly(time_series_calc.mean)
  end

  def for_two_weekly
    weekly_to_monthly(time_series_calc.mean / 2.0)
  end

  def for_four_weekly
    weekly_to_monthly(time_series_calc.mean / 4.0)
  end

  def weekly_to_monthly(weekly)
    weekly * weeks_in_year / months_in_year
  end

  def normalize_monthly
    return time_series_calc.mean if time_series_calc.max_variance >= NORMAL_VARIANCE_THRESHOLD

    time_series_calc.latest_value
  end

  def time_series_calc
    @time_series_calc = TimeSeriesCalculator.new(time_series)
  end

  def weeks_in_year
    52
  end

  def months_in_year
    12.0
  end
end
