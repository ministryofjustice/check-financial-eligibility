require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "action_cable/engine"
# require "sprockets/railtie"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module CheckFinancialEligibility
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0
    config.active_record.legacy_connection_handling = false
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true

    config.x.application.allow_future_submission_date = ENV["ALLOW_FUTURE_SUBMISSION_DATE"] || false
    config.x.status.build_date = ENV["BUILD_DATE"] || "Not Available"
    config.x.status.build_tag = ENV["BUILD_TAG"] || "Not Available"
    config.x.status.app_branch = ENV["APP_BRANCH"] || "Not Available"
    config.x.use_test_threshold_data = ENV["USE_TEST_THRESHOLD_DATA"]
    config.autoload_paths += %W[#{config.root}/app/validators]

    config.x.legal_framework_api_host = ENV["LEGAL_FRAMEWORK_API_HOST"]
  end
end
