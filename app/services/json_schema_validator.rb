class JsonSchemaValidator
  SCHEMA_PATH = Rails.root.join('public/schemas/assessment_request.json').to_s

  def initialize(payload)
    @payload = payload
  end

  def errors
    @errors ||= JSON::Validator.fully_validate(SCHEMA_PATH, payload)
  end

  def valid?
    errors.empty?
  end

  private

  attr_reader :payload
end
