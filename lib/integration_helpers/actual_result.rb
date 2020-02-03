class ActualResult
  def initialize(hash)
    @hash = hash
  end

  def assessment_result
    @hash[:assessment][:assessment_result]
  end

  def gross_income
    @hash[:assessment][:gross_income]
  end

  def other_income
    gross_income[:monthly_other_income]
  end

  def state_benefits
    gross_income[:monthly_state_benefits]
  end

  def total_gross_income
    gross_income[:total_gross_income]
  end

  def gross_income_upper_threshold
    gross_income[:upper_threshold]
  end

  def disposable_income
    @hash[:assessment][:disposable_income]
  end

  def disposable_income_assessment_result
    disposable_income[:assessment_result]
  end

  def total_outgoings_and_allowances
    disposable_income[:total_outgoings_and_allowances]
  end

  def total_disposable_income
    disposable_income[:total_disposable_income]
  end

  def disposable_income_lower_threshold
    disposable_income[:lower_threshold]
  end

  def disposable_income_upper_threshold
    disposable_income[:upper_threshold]
  end

  def income_contribution
    disposable_income[:income_contribution]
  end

  def capital
    @hash[:assessment][:capital]
  end

  def capital_assessment_result
    capital[:assessment_result]
  end

  def total_liquid
    capital[:total_liquid]
  end

  def total_non_liquid
    capital[:total_non_liquid]
  end

  def total_vehicle
    capital[:total_vehicle]
  end

  def total_mortgage_allowance
    capital[:total_mortgage_allowance]
  end

  def pensioner_capital_disregard
    capital[:pensioner_capital_disregard]
  end

  def assessed_capital
    capital[:assessed_capital]
  end

  def capital_lower_threshold
    capital[:lower_threshold]
  end

  def capital_upper_threshold
    capital[:upper_threshold]
  end

  def total_capital
    capital[:total_capital]
  end

  def capital_contribution
    capital[:capital_contribution]
  end
end
