class YamlStore
  KeyNotRecognisedError = Class.new(StandardError)

  class << self
    def from_yaml_file(path)
      hash = YAML.load_file(path)
      new(hash)
    end
  end

  attr_reader :data

  def initialize(hash)
    @data = hash.deep_symbolize_keys
  end

  def value(key)
    data[key] || raise(KeyNotRecognisedError, "key '#{key}' not set")
  end
end
