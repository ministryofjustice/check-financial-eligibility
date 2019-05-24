class AssessmentParticulars
  SETTER_METHOD_REGEX = /^[a-z][a-z0-9_]+[=]$/.freeze
  NON_SETTER_METHOD_REGEX = /^[a-z][a-z0-9_]+$/.freeze
  VALID_METHOD_REGEX = /^[a-z][a-z0-9_]+[=]?$/.freeze

  def initialize(assessment)
    @data = JSON.parse(initial_data(assessment).to_json, object_class: OpenStruct)
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
    return true if setter_method?(method, args)

    return true if getter_method?(method, args)

    false
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
        details: {},
        errors: []
      }
    }
  end
end
