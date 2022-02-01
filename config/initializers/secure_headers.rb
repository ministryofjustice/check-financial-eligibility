SecureHeaders::Configuration.configure do |config|
  # rubocop:disable Lint/PercentStringArray
  config.csp = {
    default_src: %w['self'],
    script_src: %w['self'],
    img_src: %w['self' data:],
    style_src: %w['self' 'unsafe-inline'],
  }
  # rubocop:enable Lint/PercentStringArray
end
