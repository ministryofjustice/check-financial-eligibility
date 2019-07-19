class TimeSeriesCalculator
  attr_reader :data

  def initialize(data)
    @data = data
  end

  def mean
    values.mean
  end

  def max_variance
    values.range
  end

  def latest_value
    @latest_value ||= sorted_data.values.last
  end

  def standard_deviation
    values.standard_deviation
  end

  def average_days_between_dates
    days_between_dates.mean
  end

  def deviation_between_dates
    days_between_dates.standard_deviation
  end

  def days_between_dates
    @days_between_dates ||= begin
      days = dates.each_cons(2).map { |a, b| ((a - b) / 1.day).abs.round(0) }
      DescriptiveStatistics::Stats.new days
    end
  end

  def days
    @days ||= DescriptiveStatistics::Stats.new(dates.map(&:day))
  end

  def dates
    sorted_data.keys
  end

  def values
    @values ||= DescriptiveStatistics::Stats.new(sorted_data.values)
  end

  def sorted_data
    @sorted_data ||= data.sort.to_h
  end
end
