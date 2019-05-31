class CalculationPeriod
  attr_reader :period_start, :period_end

  def initialize(submission_date)
    submission_date = submission_date
    @period_end = submission_date - 1.day
    @period_start = @period_end - 3.months
  end

  def contains?(time)
    time > @period_start.beginning_of_day && time < @period_end.end_of_day
  end
end
