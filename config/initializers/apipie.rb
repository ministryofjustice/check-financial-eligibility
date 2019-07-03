Dir[File.join(__dir__, '../../app/validators', '*.rb')].each { |file| require file }

Apipie.configure do |config|
  config.app_name                = 'Check Financial Eligibility API'
  config.api_base_url            = '/'
  config.doc_base_url            = '/apidocs'
  config.api_routes = Rails.application.routes
  # where is your API defined?
  config.api_controllers_matcher = "#{Rails.root}/app/controllers/**/*.rb"
  config.translate = false
  config.show_all_examples = true
end
