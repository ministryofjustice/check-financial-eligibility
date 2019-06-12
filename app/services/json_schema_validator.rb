class JsonSchemaValidator
  def initialize(payload, schema_path)
    @payload = payload
    @schema_path = schema_path
  end

  def errors
    @errors ||= JSON::Validator.fully_validate(@schema_path, @payload)
  end

  def valid?
    errors.empty?
  end
end
