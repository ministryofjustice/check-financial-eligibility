class JsonValidator
  def initialize(schema, payload)
    @schema = Rails.root.join(schema).to_s
    @payload = payload
  end

  def valid?
    JSON::Validator.validate(@schema, @payload)
  end

  def errors
    JSON::Validator.fully_validate(@schema, @payload)
  end
end
