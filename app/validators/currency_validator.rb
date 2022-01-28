class CurrencyValidator < Apipie::Validator::BaseValidator
  STANDARD_REGEX =  /\A^[-+]?\d+(\.\d{1,2})?\Z$/.freeze
  NO_NEGATIVE_REGEX = /\A^[+]?\d+(\.\d{1,2})?\Z$/.freeze

  def self.build(param_description, argument, options, _block)
    new(param_description, options[:currency_option]) if argument == :currency
  end

  def initialize(param_description, option = nil)
    super(param_description)
    @option = option
  end

  def validate(value)
    regex = @option == :not_negative ? NO_NEGATIVE_REGEX : STANDARD_REGEX
    regex.match?(value.to_s)
  end

  def description
    if @option == :not_negative
      "Must be a decimal, zero or greater, with a maximum of two decimal places. For example: 123.34"
    else
      "Must be a decimal with a maximum of two decimal places. For example: 123.34"
    end
  end
end
