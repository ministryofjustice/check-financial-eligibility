class JsonValidator
  def initialize(schema_name, payload)
    @schema_dir = Rails.root.join('public/schemas')
    @payload = payload
    @schema= load_schema(schema_name)
    puts ">>>>>>>>>  #{__FILE__}:#{__LINE__} <<<<<<<<<<".yellow
    puts @schema
    puts ">>>>>>>>>  #{__FILE__}:#{__LINE__} <<<<<<<<<<".yellow
    
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
