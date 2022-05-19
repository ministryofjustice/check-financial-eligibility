class JsonValidator
  def initialize(schema, payload)
    @schema_dir = Rails.root.join("public/schemas")
    @schema = load_schema(schema)
    @payload = payload
  end

  def valid?
    JSON::Validator.validate(@schema, @payload)
  end

  def errors
    JSON::Validator.fully_validate(@schema, @payload)
  end

private

  def load_schema(schema_name)
    filename = "#{@schema_dir}/#{schema_name}.json.erb"
    ERB.new(File.read(filename)).result(binding)
  end
end
