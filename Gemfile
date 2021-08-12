source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.0.2'

gem 'active_model_serializers', '~> 0.10.12'
# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 6.1.4'
# Use postgresql as the database for Active Record
gem 'pg', '>= 0.18', '< 2.0'
# Use Puma as the app server
gem 'puma', '~> 5.4'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use ActiveStorage variant
# gem 'mini_magick', '~> 4.8'

gem 'sentry-rails', '>= 4.4.0'
gem 'sentry-ruby'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false

gem 'business', '~> 2.2'
# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
# gem 'rack-cors'

gem 'colorize'

gem 'json-schema', '>= 2.8.1'

# Seeding tools
gem 'dibber'

# Api documentation
gem 'apipie-rails', '>= 0.5.18'

# Adds Statistical methods to objects such as arrays
gem 'descriptive_statistics', require: 'descriptive_statistics/safe'

gem 'google_drive', '>= 3.0.7'

# parse spreadsheets
gem 'roo', '~> 2.8.3'

# Manage security headers
gem 'secure_headers'

gem 'webpacker', '~> 5', '>= 5.3.0'

group :development, :test do
  gem 'awesome_print'
  gem 'dotenv-rails', '>= 2.7.6'
  gem 'factory_bot_rails', '>= 6.2.0'
  gem 'faker'
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'pry-byebug'
  gem 'rspec-rails', '~> 5.0', '>= 5.0.1'
  gem 'rubocop', require: false
  gem 'rubocop-performance'
  gem 'rubocop-rails', require: false
  gem 'timecop'
end

group :development do
  gem 'guard'
  gem 'guard-rspec'
  gem 'guard-rubocop'
  gem 'listen', '>= 3.0.5', '< 3.7'
  gem 'pry-rescue'
  gem 'pry-stack_explorer'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :test do
  gem 'codecov', require: false
  gem 'database_cleaner'
  gem 'shoulda-matchers'
  gem 'simplecov', require: false
  gem 'simplecov-rcov'
  gem 'vcr'
  gem 'webmock', '>= 3.13.0'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data'

# Identify file types before uploads
gem 'mimemagic', '>= 0.4.3'
