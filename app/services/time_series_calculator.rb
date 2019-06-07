class TimeSeriesCalculator

  attr_reader :data

  def initialize(data)
    @data = data
  end
  delegate :values, to: :data

  def mean
    values.mean
  end

  def average_days_between_dates
    days_between_dates.mean
  end

  def days_between_dates
    @days_between_dates ||= begin
      days = dates.each_cons(2).map {|a,b| ((a - b) / 1.day).abs.round(0)}
      DescriptiveStatistics::Stats.new(days)
    end
  end

  def deviation_between_dates
    days_between_dates.standard_deviation
  end

  def dates
    data.keys
  end

  def values
    @values ||= DescriptiveStatistics::Stats.new(data.values)
  end
end
