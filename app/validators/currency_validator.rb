class CurrencyValidator < Apipie::Validator::BaseValidator
  def self.build(param_description, argument, _options, _block)
    new(param_description) if argument == :currency
  end

  def validate(value)
    value.to_s =~ /\A^[-+]?\d+(\.\d{1,2})?\Z$/
  end

  def description
    'Must be a decimal with a maximum of two decimal places. For example: 123.34'
  end
end
