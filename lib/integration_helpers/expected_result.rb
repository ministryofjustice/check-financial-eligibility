class ExpectedResult
  PASSPORTED_METHODS = %i[
    assessment_result
    capital_assessment_result
    total_liquid
    total_non_liquid
    total_vehicle
    total_mortgage_allowance
    total_capital
    pensioner_capital_disregard
    assessed_capital
    capital_lower_threshold
    capital_upper_threshold
    assessment_result
    capital_contribution
  ].freeze

  NON_PASSPORTED_METHODS = %i[
    assessment_result
    other_income
    state_benefits
    total_gross_income
    gross_income_upper_threshold
    disposable_income_assessment_result
    total_outgoings_and_allowances
    total_disposable_income
    disposable_income_lower_threshold
    disposable_income_upper_threshold
    income_contribution
    capital_assessment_result
    total_liquid
    total_non_liquid
    total_vehicle
    total_mortgage_allowance
    total_capital
    pensioner_capital_disregard
    assessed_capital
    capital_lower_threshold
    capital_upper_threshold
    capital_contribution
  ].freeze

  def initialize(expected_result_hash)
    @expected_result = expected_result_hash
    @actual_result = nil
  end

  def passported?
    @expected_result[:assessment][:passported]
  end

  def methods
    passported? ? PASSPORTED_METHODS : NON_PASSPORTED_METHODS
  end

  def ==(other)
    @actual_result = other
    display_differences
  end

  private

  def verbose?
    ENV['VERBOSE'].in? %w[true noisy]
  end

  # :nocov:
  def all_values_equal
    methods.each do |method|
      return false if __send__(method).to_s != @actual_result.__send__(method)
    end
  end
  # :nocov:

  def display_differences
    results = []
    display_differences_header if verbose?
    methods.each { |method| results << display_differences_for(method) }
    result = results.uniq == [true]
    display_differences_footer(result) if verbose?
    result
  end

  # :nocov:
  def display_differences_header
    header_pattern = '%40s  %-22s %-22s'
    puts format(header_pattern, '', 'Expected', 'Actual')
    puts format(header_pattern, '', '=========', '=========')
  end
  # :nocov:

  def display_differences_for(method)
    color = :green
    result = true
    expected_value = __send__(method).to_s
    actual_value = @actual_result.__send__(method)
    # :nocov:
    if expected_value != actual_value
      result = false
      color = :red
    end
    # :nocov:
    puts format(difference_pattern, method.to_s, expected_value, actual_value).colorize(color) if verbose?
    result
  end

  # :nocov:
  def display_differences_footer(result)
    result == true ? puts('SUCCESS'.colorize(:green)) : puts('FAIL'.colorize(:red))
  end

  def difference_pattern
    @difference_pattern ||= '%40s: %-22s %-22s'.freeze
  end
  # :nocov:

  def assessment_result
    @expected_result[:assessment][:assessment_result]
  end

  def gross_income
    @expected_result[:gross_income_summary]
  end

  def other_income
    gross_income[:monthly_other_income]
  end

  def gross_income_upper_threshold
    gross_income[:upper_threshold]
  end

  def state_benefits
    gross_income[:monthly_state_benefits]
  end

  def total_gross_income
    gross_income[:total_gross_income]
  end

  def disposable_income
    @expected_result[:disposable_income_summary]
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
    @expected_result[:capital]
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
