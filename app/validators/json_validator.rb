class JsonValidator
  def initialize(schema_name, payload)
    @schema_name = schema_name
    @payload = payload
  end

  def valid?
    JSON::Validator.validate(schema, @payload)
  end

  def errors
    # This return has the 'attribute(reason)' for the error (e.g. 'Enum', 'Required'), the 'fragment' (aka JSON path)
    # a 'schema' key and the 'message' (which is the return when errors_as_objects is false)
    JSON::Validator.fully_validate(schema, @payload, errors_as_objects: true).map { |x| x.fetch(:message) }
  end

private

  attr_reader :schema_name

  def schema
    @schema ||= load_schema
  end

  def load_schema
    filename = "#{schema_dir}/#{schema_name}.json.erb"
    ERB.new(File.read(filename)).result(binding)
  end

  def schema_dir
    @schema_dir ||= Rails.root.join("public/schemas")
  end
end
