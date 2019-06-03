class AssessmentParticulars
  SETTER_METHOD_REGEX = /^[a-z][a-z0-9_]+[=]$/.freeze
  NON_SETTER_METHOD_REGEX = /^[a-z][a-z0-9_]+$/.freeze
  VALID_METHOD_REGEX = /^[a-z][a-z0-9_]+[=]?$/.freeze

  def initialize(assessment)
    @data = JSON.parse(initial_data(assessment).to_json, object_class: DatedStruct)
  end

  def self.initial_property_details
    {
      notional_sale_costs_pctg: 0.0,
      net_value_after_deduction: 0.0,
      maximum_mortgage_allowance: 0.0,
      net_value_after_mortgage: 0.0,
      percentage_owned: 0.0,
      net_equity_value: 0.0,
      property_disregard: 0.0,
      assessed_capital_value: 0.0
    }
  end

  def self.initial_vehicle_details
    {
      value: 0.0,
      loan_amount_outstanding: 0.0,
      date_of_purchase: nil,
      in_regular_use: true,
      assessed_value: 0.0
    }
  end

  def method_missing(method, *args)
    super unless valid_missing_method?(method, args)
    @data.__send__(method, *args)
  end

  def respond_to_missing?(method, _include_private = false)
    VALID_METHOD_REGEX.match?(method)
  end

  private

  def valid_missing_method?(method, args)
    setter_method?(method, args) || getter_method?(method, args)
  end

  def setter_method?(method, args)
    args.size == 1 && SETTER_METHOD_REGEX.match?(method)
  end

  def getter_method?(method, args)
    args.size.zero? && NON_SETTER_METHOD_REGEX.match?(method)
  end

  def initial_data(assessment)
    {
      request: JSON.parse(assessment.request_payload),
      response: {
        assessment_id: assessment.id,
        client_reference_id: assessment.client_reference_id,
        details: initial_details,
        errors: []
      }
    }
  end

  def initial_details
    {
      passported: nil,
      self_employed: nil,
      income: initial_income_details,
      capital: initial_capital_details,
      contributions: initial_contributions_details
    }
  end

  def initial_income_details
    {
      monthly_gross_income: 0.0,
      upper_income_threshold: 0.0,
      monthly_disposable_income: 0.0,
      disposable_income_lower_threshold: 0.0,
      disposable_income_upper_threshold: 0.0
    }
  end

  def initial_capital_details
    {
      liquid_capital_assessment: 0.0,
      property: {
        main_dwelling: AssessmentParticulars.initial_property_details,
        additional_properties: []
      },
      vehicles: [],
      total_capital_lower_threshold: 0.0,
      total_capital_upper_threshold: 0.0,
      disposable_capital_assessment: 0.0
    }
  end

  def initial_contributions_details
    {
      monthly_contribution: 0.00,
      capital_contribution: 0.00
    }
  end
end
