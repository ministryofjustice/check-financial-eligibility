class JsonSchemaValidator
  SCHEMA_PATH = File.join(Rails.root, 'config', 'api', 'assessment_schema.json')

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
