class SalaryPatternGenerator
  def self.call(*args)
    new(*args).call
  end

  attr_reader :period, :salary, :day_offset, :salary_offset, :start_at

  def initialize(period:, salary: 100, day_offset: nil, salary_offset: nil, start_at: Time.now.utc)
    @period = period
    @salary = salary
    @salary_offset = salary_offset
    @offset = day_offset
    @day_offset = @offset
    @start_at = start_at
  end

  def call
    case period
    when :monthly_set_day
      generate_monthly_set_day
    when :monthly
      generate_monthly
    when :weekly
      generate_weekly
    when :two_weekly
      generate_weekly(2)
    when :four_weekly
      generate_weekly(4)
    end
  end

  def generate_monthly_set_day
    (0..2).each_with_object({}) do |offset, hash|
      day = start_at.to_date << offset
      time = weekend_offset(day.to_time)
      hash[time] = sample_salary
    end
  end

  def weekend_offset(day) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity
    return day unless day.wday > 5 && day_offset

    case day_offset
    when 1
      day.saturday? ? day - 1.day : day + 1
    when 2
      day.saturday? ? day + 2.day : day + 1
    else
      day + day_offset.days
    end
  end

  def generate_monthly
    dates_for 0..2, :month
  end

  def generate_weekly(step = 1)
    weeks = (3.months / 1.week).to_i
    dates_for (0..weeks).step(step), :week
  end

  def dates_for(points, method)
    points.each_with_object({}) do |n, h|
      time = sample_day(n.__send__(method).ago + start_offset)
      h[time] = sample_salary
    end
  end

  def sample_day(day)
    return day unless day_offset

    offset = sample_around 0, day_offset
    day + offset.days
  end

  def sample_salary
    return salary unless salary_offset

    sample_around salary, salary_offset
  end

  def sample_around(middle, offset)
    first = middle - offset
    last = middle + offset
    (first..last).to_a.sample
  end

  def start_offset
    @start_offset ||= start_at_normalized - Time.now.utc.beginning_of_day
  end

  def start_at_normalized
    @start_at_normalized ||= (start_at.utc.beginning_of_day + 1.day)
  end
end
