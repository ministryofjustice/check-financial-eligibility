class AssessmentService
  HTTP_SUCCESS = 200
  HTTP_UNPROCESSABLE_ENTITY = 422

  attr_reader :response_payload, :http_status

  def initialize(_remote_ip, request_payload)
    @request_payload = request_payload
    @assessment = Assessment.create!(remote_ip: request.remote_ip, request_payload: @request_payload)
  end

  def call
    validator = JsonSchemaValidator.new(@request_payload)
    if validator.valid?
      process_payload
    else
      parse_errors(validator)
    end
  end

  private

  def process_payload; end

  def parse_errors(validator); end
end
