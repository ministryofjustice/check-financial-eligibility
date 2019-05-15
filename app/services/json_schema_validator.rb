class JsonSchemaValidator

  SCHEMA_PATH = File.join(Rails.root, 'config', 'api', 'assessment_schema.json')

  attr_reader :errors

  def initialize(payload)
    @payload = payload
    @errors = []
  end

  def run
    @errors = JSON::Validator.fully_validate(SCHEMA_PATH, @payload)
  end

  def valid?
   @errors.empty?
  end
end
