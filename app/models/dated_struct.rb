class DatedStruct < OpenStruct
  DATE_REGEX = /^([12][9|0][0-9]{2}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01]))$/.freeze

  def initialize(hash = nil)
    @table = {}
    hash&.each_pair do |k, v|
      k = k.to_sym
      @table[k] = value_or_time(v)
    end
  end

  def []=(name, value)
    modifiable?[new_ostruct_member!(name)] = value_or_time(value)
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
