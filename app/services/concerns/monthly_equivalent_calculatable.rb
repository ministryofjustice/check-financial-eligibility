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

  def monthly_regular_transaction_amount_by(operation:, category:)
    transactions = gross_income_summary.regular_transactions.where(operation:).where(category:)

    all_monthly_amounts = transactions.each_with_object([]) do |transaction, amounts|
      calc_method = determine_calc_method(transaction.frequency)
      amounts << send(calc_method, transaction.amount)
    end

    all_monthly_amounts.sum
  end
end
