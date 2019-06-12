class AssessmentCreationService
  SCHEMA_PATH = Rails.root.join('public/schemas/assessment.json').to_s

  attr_reader :http_status

  def initialize(remote_ip, raw_post)
    @raw_post = raw_post
    @assessment_hash = JSON.parse(raw_post).merge(remote_ip: remote_ip)
  end

  def response_payload
    @validator = JsonSchemaValidator.new(@raw_post, SCHEMA_PATH)
    if @validator.valid? && create_assessment
      @http_status = 200
      @response = success_response
    else
      @http_status = 422
      @response = error_response
    end
    @response.to_json
  end

  private

  def create_assessment
    @assessment = Assessment.new(@assessment_hash)
    @assessment.save
  end

  def success_response
    {
      status: :ok,
      assessment_id: @assessment.id,
      links: [
        {
          href: "https://check-for-legal-aid-eligibility/assessment/#{@assessment.id}/applicant",
          rel: 'applicant',
          type: 'POST'
        }
      ]
    }
  end

  def error_response
    errors = @validator.valid? ? @assessment.errors.full_messages : @validator.errors
    {
      status: :error,
      errors: errors
    }
  end
end
