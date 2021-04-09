require 'sentry-ruby'
require 'sentry-rails'

if %w[production].include?(Rails.env) && ENV['SENTRY_DSN'].present?
  Sentry.init do |config|
    config.dsn = ENV['SENTRY_DSN']

    filter = ActiveSupport::ParameterFilter.new(Rails.application.config.filter_parameters.map(&:to_s))

    config.before_send = ->(event, _hint) do
      filter.filter(event.to_hash)
    end
  end
end
