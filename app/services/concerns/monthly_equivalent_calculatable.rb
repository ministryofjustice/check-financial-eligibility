module MonthlyEquivalentCalculatable
private

  def determine_calc_method(period)
    case period.to_sym
    when :monthly
      :monthly_to_monthly
    when :four_weekly
      :four_weekly_to_monthly
    when :two_weekly
      :two_weekly_to_monthly
    when :weekly
      :weekly_to_monthly
    when :unknown
      :blunt_average
    else
      raise ArgumentError, "unexpected period #{period}"
    end
  end

  def monthly_to_monthly(value)
    value
  end

  def four_weekly_to_monthly(value)
    (value / 4 * 52 / 12).round(2)
  end

  def two_weekly_to_monthly(value)
    (value / 2 * 52 / 12).round(2)
  end

  def weekly_to_monthly(value)
    (value * 52 / 12).round(2)
  end
end
