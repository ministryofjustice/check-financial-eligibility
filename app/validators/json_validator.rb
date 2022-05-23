class JsonValidator
  def initialize(schema_name, payload)
    @schema_dir = Rails.root.join("public/schemas")
    @schema_name = load_schema(schema_name)
    @payload = payload
  end

  def valid?
    JSON::Validator.validate(@schema_name, @payload)
  end

  def errors
    JSON::Validator.fully_validate(@schema_name, @payload)
  end

private

  def load_schema(schema_name)
    filename = "#{@schema_dir}/#{schema_name}.json.erb"
    ERB.new(File.read(filename)).result(binding)
  end
end
