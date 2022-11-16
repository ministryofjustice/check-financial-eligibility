module MonthlyEquivalentCalculatable
private

  def determine_calc_method(frequency)
    raise ArgumentError, "unexpected frequency #{frequency}" unless frequency_conversions.key?(frequency)

    frequency_conversions[frequency]
  end

  def three_monthly_to_monthly(value)
    (value / 3).round(2)
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

  def frequency_conversions
    { three_monthly: :three_monthly_to_monthly,
      monthly: :monthly_to_monthly,
      four_weekly: :four_weekly_to_monthly,
      two_weekly: :two_weekly_to_monthly,
      weekly: :weekly_to_monthly,
      unknown: :blunt_average }.with_indifferent_access
  end

  def monthly_regular_transaction_amount_by(gross_income_summary:, operation:, category:)
    transactions = gross_income_summary.regular_transactions.where(operation:).where(category:)

    all_monthly_amounts = transactions.each_with_object([]) do |transaction, amounts|
      calc_method = determine_calc_method(transaction.frequency)
      amounts << send(calc_method, transaction.amount)
    end

    all_monthly_amounts.sum
  end
end
