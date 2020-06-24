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

  def irregular_income
    gross_income[:monthly_student_loan]
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

  def mie
    gross_income[:monthly_income_equivalents]
  end

  def mie_friends_or_family
    mie[:friends_or_family]
  end

  def mie_maintenance_in
    mie[:maintenance_in]
  end

  def mie_property_or_lodger
    mie[:property_or_lodger]
  end

  def mie_student_loan
    mie[:student_loan]
  end

  def mie_pension
    mie[:pension]
  end

  def moe
    gross_income[:monthly_outgoing_equivalents]
  end

  def moe_maintenance_out
    moe[:maintenance_out]
  end

  def moe_child_care
    moe[:child_care]
  end

  def moe_rent_or_mortgage
    moe[:rent_or_mortgage]
  end

  def moe_legal_aid
    moe[:legal_aid]
  end

  def deductions
    gross_income[:deductions] || {}
  end

  def ded_dependants_allowance
    deductions[:dependants_allowance]
  end

  def ded_disregarded_state_benefits
    deductions[:disregarded_state_benefits]
  end
end
