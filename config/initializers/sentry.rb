require "sentry-ruby"
require "sentry-rails"
require "active_support/parameter_filter"

if %w[production].include?(Rails.env) && ENV["SENTRY_DSN"].present? && ENV["SENTRY"]&.casecmp("enabled")&.zero?
  Sentry.init do |config|
    config.dsn = ENV["SENTRY_DSN"]

    filter = ActiveSupport::ParameterFilter.new(Rails.application.config.filter_parameters.map(&:to_s))

    config.before_send = lambda { |event, _hint|
      filter.filter(event.to_hash)
    }
  end
end
