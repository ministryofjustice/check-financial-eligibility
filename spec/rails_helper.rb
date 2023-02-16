# This file is copied to spec/ when you run 'rails generate rspec:install'
require "spec_helper"
ENV["RAILS_ENV"] ||= "test"
require File.expand_path("../config/environment", __dir__)
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
require "rspec/rails"
require "pry-rescue/rspec" if Rails.env.development?
require "super_diff/rspec-rails"

# Add additional requires below this line. Rails is not loaded until this point!

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
Dir[Rails.root.join("spec/support/**/*.rb")].sort.each { |f| require f }

# Checks for pending migrations and applies them before tests are run.
# If you are not using ActiveRecord, you can remove these lines.
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end
RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = Rails.root.join("/spec/fixtures")

  # Path to look up fixtures using `file_fixture('file_name.blah').read`.
  # Default is "spec/fixtures/files"
  config.file_fixture_path = "spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, :type => :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")

  # remove the need to prefix every create or build with FactoryBot
  # https://github.com/thoughtbot/factory_bot/blob/master/GETTING_STARTED.md#rspec
  config.include FactoryBot::Syntax::Methods
  config.include RequestHelpers, type: :request
  config.include ActiveSupport::Testing::TimeHelpers

  config.before(:suite) do
    Faker::Config.locale = "en-GB"
    DatabaseCleaner.clean_with :truncation
  end
  config.after(:suite) do
    DatabaseCleaner.clean_with :truncation
  end
end

require "webmock/rspec"

require Rails.root.join("spec/fixtures/base_assessment_fixture")
require Rails.root.join("spec/fixtures/assessment_request_fixture")
require Rails.root.join("spec/fixtures/assessment_response_fixture")

# helper methods
def stub_call_to_json_schema
  stub_request(:get, "http://localhost:3000/schemas/assessment_request.json")
    .to_return(status: 200, body: json_schema_definitions)
end

def json_schema_definitions
  File.read(Rails.root.join("public/schemas/assessment_request.json"))
end

def deep_match(actual, expected)
  expect(actual.keys.sort).to eq expected.keys.sort
  actual.each do |key, ids|
    expect(ids).to match_array(expected[key])
  end
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end
