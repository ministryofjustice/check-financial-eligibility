# See https://github.com/Apipie/apipie-rails#adding-custom-validator
# Note: the server needs to be restarted for changes to this file to take effect.
class DateValidator < Apipie::Validator::BaseValidator
  def self.build(param_description, argument, options, _block)
    new(param_description, options[:date_option]) if argument == Date
  end

  attr_reader :option

  def initialize(param_description, option = nil)
    super(param_description)
    @option = option
  end

  def validate(value)
    return false unless value.present? && date_parsable?(value)
    return true if option.nil?

    date = Date.parse(value)

    validate_options(option, date)
  end

  def validate_options(option, date)
    case option
    when :today_or_older
      return true if date <= Date.today
    when :submission_date_today_or_older
      return true if (date <= Date.today || allow_future_submission_date?)
    else
      raise "date option '#{option}' not recognised"
    end
  end

  def allow_future_submission_date?
    Rails.configuration.x.application.allow_future_submission_date
  end

  def description
    text = ['Date must be parsable']
    text << 'in the past' if option == :today_or_older
    "#{text.to_sentence}. For example: '2019-05-23'"
  end

  private

  def date_parsable?(string)
    date_hash = Date._parse(string)
    Date.valid_date?(date_hash[:year].to_i, date_hash[:mon].to_i, date_hash[:mday].to_i)
  end
end
