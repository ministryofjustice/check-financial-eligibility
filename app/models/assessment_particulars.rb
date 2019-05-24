class AssessmentParticulars < RecursiveOpenStruct

  def initialize(assessment)
    @data = RecursiveOpenStruct.new(initial_data(assessment), recurse_over_arrays: true)
  end

  def method_missing(method, *args)
    @data.__send__(method, *args)
  end

  private

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
