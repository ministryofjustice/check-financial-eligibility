class AssessmentParticulars < RecursiveOpenStruct
  def initialize(assessment)
    super initial_data(assessment), recurse_over_arrays: true
  end

  private

  def initial_data(assessment)
    {
      request: RecursiveOpenStruct.new(JSON.parse(assessment.request_payload), recurse_over_arrays: true),
      response: RecursiveOpenStruct.new(initial_response_data(assessment), recurse_over_arrays: true)
    }
  end

  def initial_response_data(assessment)
    {
      assessment_id: assessment.id,
      client_reference_id: assessment.client_reference_id,
      details: RecursiveOpenStruct.new({}, recurse_over_arrays: true),
      errors: []
    }
  end
end
