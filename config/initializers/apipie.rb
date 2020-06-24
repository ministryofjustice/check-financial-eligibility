Dir[File.join(__dir__, '../../app/validators', '*.rb')].sort.each { |file| require file }

Apipie.configure do |config|
  config.app_name                = 'Check Financial Eligibility API'
  config.api_base_url            = '/'
  config.doc_base_url            = '/apidocs'
  config.api_routes = Rails.application.routes
  # where is your API defined?
  config.api_controllers_matcher = "#{Rails.root}/app/controllers/**/*.rb"
  config.translate = false
  config.validate = true
  config.show_all_examples = true
  config.app_info = <<-END_OF_TEXT


    == Check Financial Eligibility API

    = Overview
    This API is used to determine the finanical eligibility of an applicant for Legal Aid

    == Usage
    The first step is to create an assessment via:

      POST /assessments

    The response to this action includes an assessment id that can then be used in the following steps:

      POST /assessments/:assessment_id/applicant      # adds data about the applicant
      POST /assessments/:assessment_id/capitals       # adds data about liquid assets (i.e. bank accounts) and non-liquid assets (valuable items, trusts, etc)
      POST /assessments/:assessment_id/dependants     # adds data about any dependants the applicant may have
      POST /assessments/:assessment_id/outgoings      # adds data about applicant's outgoings
      POST /assessments/:assessment_id/properties     # adds data about properties owned by the applicant
      POST /assessments/:assessment_id/other_incomes  # adds data about applicant's other sources of income
      POST /assessments/:assessment_id/irregular_income  # adds data about applicant's irregular income
      POST /assessments/:assessment_id/state_benefits # adds data about applicant's income from state benefits
      POST /assessments/:assessment_id/vehicles       # adds data about vehicles owned by the applicant

    Once all the above calls have been made to build up a complete picture of the applicant's assets and income
    the following call should be made to perform the assessment and get the result:

      GET /assessment/:assessment_id

    == Reference data

    A list of state_benefit types, their full names, and the labels to use when posting to the state_benfits endpoint can
    be obtained from this endpoint:

    GET /state_benefit_type

  END_OF_TEXT
end
