class JsonSwaggerValidator
  def initialize(schema_name, payload)
    @payload = payload

    swagger_yaml = YAML.load_file(Rails.root.join("swagger/v5/swagger.yaml"))
    endpoint_yaml = swagger_yaml.dig("paths", endpoint(schema_name))
    components = swagger_yaml.fetch("components")
    @schema = endpoint_yaml.dig("post", "requestBody", "content", "application/json", "schema").merge(components:)
  end

  def valid?
    JSON::Validator.validate(@schema, @payload)
  end

  def errors
    JSON::Validator.fully_validate(@schema, @payload)
  end

private

  def endpoint(schema_name)
    if schema_name.starts_with?("/")
      schema_name
    else
      "/assessments/{assessment_id}/#{schema_name}"
    end
  end
end
