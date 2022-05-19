class JsonValidator
  def initialize(schema, payload)
    @schema = File.read(Rails.root.join(schema))
    @payload = payload
  end

  def valid?
    JSON::Validator.validate(@schema, @payload)
  end

  def errors
    JSON::Validator.fully_validate(@schema, @payload)
  end
end
