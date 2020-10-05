SecureHeaders::Configuration.configure do |config|
  # rubocop:disable Lint/PercentStringArray
  config.csp = {
    default_src: %w['none'],
    script_src: %w['none']
  }
  # rubocop:enable Lint/PercentStringArray
end
