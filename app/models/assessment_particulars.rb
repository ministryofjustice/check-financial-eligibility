class AssessmentParticulars
  def initialize(assessment)
    @data = JSON.parse(initial_data(assessment).to_json, object_class: OpenStruct)
  end

  def method_missing(method, *args)
    super unless valid_missing_method?(method, args)
    @data.__send__(method, *args)
  end

  def respond_to_missing?(method, include_private = false)
    @data.respond_to?(method, include_private)
  end

  private

  def valid_missing_method?(method, args)
    return true if args.size.zero? && !method.match?(/=$/)

    return true if args.size.zero? && method.match?(/=$/)

    false
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
