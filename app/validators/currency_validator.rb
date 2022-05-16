class CurrencyValidator < ActiveModel::Validations::NumericalityValidator
  STANDARD_REGEX =  /\A^[-+]?\d+(\.\d{1,2})?\Z$/
  NO_NEGATIVE_REGEX = /\A^[+]?\d+(\.\d{1,2})?\Z$/

  def validate_each(record, attr_name, value)
    not_negative = options[:not_negative]
    regex = not_negative == true ? NO_NEGATIVE_REGEX : STANDARD_REGEX
    record.errors.add(attr_name, description(not_negative)) unless regex.match?(value.to_s)
  end

  def description(not_negative)
    if not_negative == true
      "Must be a decimal, zero or greater, with a maximum of two decimal places. For example: 123.34"
    else
      "Must be a decimal with a maximum of two decimal places. For example: 123.34"
    end
  end
end
