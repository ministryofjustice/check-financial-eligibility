class JsonSwaggerValidator
  def initialize(schema_name, payload)
    @schema_name = schema_name
    @payload = payload

    swagger_yaml = YAML.load_file(Rails.root.join("swagger/v5/swagger.yaml"))
    endpoint = swagger_yaml.dig("paths", "/assessments/{assessment_id}/#{schema_name}")
    components = swagger_yaml.fetch("components")
    @schema = endpoint.dig("post", "requestBody", "content", "application/json", "schema").merge(components:)
  end

  def valid?
    JSON::Validator.validate(@schema, @payload)
  end

  def errors
    JSON::Validator.fully_validate(@schema, @payload)
  end
end
