class DatedStruct < OpenStruct
  DATE_REGEX = /^([12][9|0][0-9]{2}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01]))$/.freeze

  # Initialize with options serialize_as_open_struct: true if you want the #to_json method
  # to generate an intermediate "table" key, as does OpenStruct
  #
  def initialize(hash = nil, options = {})
    @options = options
    @table = {}
    hash&.each_pair do |k, v|
      k = k.to_sym
      @table[k] = value_or_time(v)
    end
  end

  # TODO: remove this method (or even the whole class) once all reference to it has been removed from other old_services
  # :nocov:
  def []=(name, value)
    modifiable?[new_ostruct_member!(name)] = value_or_time(value)
  end
  # :nocov:

  # OpenStruct will normally serialize to JSON with an intermediate key 'table'.
  # DatedStruct will only do it if created with option {serialize_as_open_struct: true}
  def to_hash
    if @options[:serialize_as_open_struct]
      instance_values.except!('options').as_json
    else
      to_h
    end
  end

  private

  def value_or_time(value)
    if value.is_a?(String) && DATE_REGEX.match?(value)
      Date.parse(value)
    else
      value
    end
  end
end
