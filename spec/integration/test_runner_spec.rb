require 'rails_helper'
Dir[Rails.root.join('lib/integration_helpers/*.rb')].sort.each { |f| require f }

# NOTE 1:
# Use the VERBOSE environment variable to control how much output is displayed:
# * not_set: no output
# * true: outputs the test name and expected vs. actual results
# * noisy: as for true, but with all request and response payloads as well
#
# NOTE 2:
# To test just one worksheet rather than all, set TARGET_WORKSHEET env var to the name of the worksheet.
#

RSpec.describe 'IntegrationTests::TestRunner', type: :request do
  let(:spreadsheet_file) { Rails.root.join('tmp/integration_test_data.xlsx') }
  let(:spreadsheet) { Roo::Spreadsheet.open(spreadsheet_file.to_s) }
  let(:worksheet_names) { spreadsheet.sheets }
  let(:headers) { { 'CONTENT_TYPE' => 'application/json', 'Accept' => 'application/json;version=2' } }
  let(:target_worksheet) { ENV['TARGET_WORKSHEET'] }

  # rubocop:disable Style/StringLiterals
  def google_secret
    {
      "type": 'service_account',
      "project_id": 'laa-apply-for-legal-aid',
      "private_key_id": ENV['PRIVATE_KEY_ID'],
      "private_key": ENV['PRIVATE_KEY'].gsub("\\n", "\n"),
      "client_email": ENV['CLIENT_EMAIL'],
      "client_id": ENV['CLIENT_ID'],
      "auth_uri": 'https://accounts.google.com/o/oauth2/auth',
      "token_uri": 'https://oauth2.googleapis.com/token',
      "auth_provider_x509_cert_url": 'https://www.googleapis.com/oauth2/v1/certs',
      "client_x509_cert_url": 'https://www.googleapis.com/robot/v1/metadata/x509/laa-apply-service%40laa-apply-for-legal-aid.iam.gserviceaccount.com'
    }
  end
  # rubocop:enable Style/StringLiterals

  def local_spreadsheet_needs_replacing?(local, remote)
    return true unless File.exist?(local)

    return true if ENV['REFRESH'] == 'true'

    remote.modified_time > File.mtime(local)
  end

  before do
    Dibber::Seeder.new(StateBenefitType, 'data/state_benefit_types.yml', name_method: :label, overwrite: true).build

    secret_file = StringIO.new(google_secret.to_json)
    session = GoogleDrive::Session.from_service_account_key(secret_file)
    google_sheet = session.spreadsheet_by_title('New means assessment test data')
    if local_spreadsheet_needs_replacing?(spreadsheet_file, google_sheet)
      google_sheet.export_as_file('tmp/integration_test_data.xlsx', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
    end
  end

  OBJECT_GENERATORS = {
    applicant: ->(dataset) { PayloadGenerator.new(dataset, :applicant).run },
    dependants: ->(dataset) { ArrayPayloadGenerator.new(dataset, 'dependants', 5).run },
    other_incomes: ->(dataset) { DeeplyNestedPayloadGenerator.new(dataset, :other_incomes).run },
    state_benefits: ->(dataset) { DeeplyNestedPayloadGenerator.new(dataset, :state_benefits).run },
    outgoings: ->(dataset) { OutgoingsPayloadGenerator.new(dataset).run },
    capitals: ->(dataset) { CapitalsPayloadGenerator.new(dataset).run },
    properties: ->(dataset) { PropertyPayloadGenerator.new(dataset).run },
    vehicles: ->(dataset) { ArrayPayloadGenerator.new(dataset, 'vehicles', 4).run }
  }.freeze

  URLS = {
    applicant: ->(assessment_id) { Rails.application.routes.url_helpers.assessment_applicant_path(assessment_id) },
    capitals: ->(assessment_id) { Rails.application.routes.url_helpers.assessment_capitals_path(assessment_id) },
    vehicles: ->(assessment_id) { Rails.application.routes.url_helpers.assessment_vehicles_path(assessment_id) },
    properties: ->(assessment_id) { Rails.application.routes.url_helpers.assessment_properties_path(assessment_id) },
    other_incomes: ->(assessment_id) { Rails.application.routes.url_helpers.assessment_other_incomes_path(assessment_id) },
    earned_income: ->(assessment_id) { Rails.application.routes.url_helpers.assessment_earned_income_path(assessment_id) },
    state_benefits: ->(assessment_id) { Rails.application.routes.url_helpers.assessment_state_benefits_path(assessment_id) },
    outgoings: ->(assessment_id) { Rails.application.routes.url_helpers.assessment_outgoings_path(assessment_id) },
    dependants: ->(assessment_id) { Rails.application.routes.url_helpers.assessment_dependants_path(assessment_id) }
  }.freeze

  describe 'run integration_tests' do
    it 'passes all tests' do
      results = {}
      worksheet_names.each do |worksheet_name|
        next if target_worksheet.present? && worksheet_name != target_worksheet

        datasets = DatasetGenerator.new(spreadsheet, worksheet_name).run
        next if datasets.nil?

        assessment_id = post_assessment(datasets)
        datasets.each_key do |object_name|
          post_object(assessment_id, datasets, object_name)
        end
        get assessment_path(assessment_id), headers: headers
        expected_results = ExpectedResultsExtractor.new(spreadsheet, worksheet_name).run
        results[worksheet_name] = compare_results(worksheet_name, parsed_response, expected_results)
      end
      expect(results).to show_all_integration_tests_passed
    end

    def compare_results(worksheet_name, actual_results_hash, expected_results_hash)
      actual_result = ActualResult.new(actual_results_hash)
      noisy_pp actual_result, 'ASSESSMENT RESULT'
      expected_result = ExpectedResult.new(worksheet_name, expected_results_hash)
      expected_result == actual_result
    end

    def post_assessment(datasets)
      assessment_payload = PayloadGenerator.new(datasets['assessment']).run
      post assessments_path, params: assessment_payload.to_json, headers: headers
      if parsed_response[:success] != true
        puts 'Error creating assessment'
        ap parsed_response
        exit
      end
      datasets.delete('assessment')
      parsed_response[:objects].first[:id]
    end

    def post_object(assessment_id, datasets, object_name)
      raise "Unknown object: #{object_name}" unless object_name.to_sym.in?(OBJECT_GENERATORS)

      payload = OBJECT_GENERATORS[object_name.to_sym].call(datasets[object_name])
      noisy_pp payload, "PAYLOAD FOR #{object_name}"
      post url_for_object(object_name, assessment_id), params: payload.to_json, headers: headers
      noisy_pp parsed_response, 'RESPONSE'
    end

    def verbose?
      ENV['VERBOSE'].in? %w[true noisy]
    end

    def noisy?
      ENV['VERBOSE'] == 'noisy'
    end

    def pp_object(obj, comment, print)
      return unless print

      puts "*************************** #{comment}  #{__FILE__}:#{__LINE__} ***************** "
      pp obj
    end

    def verbose_pp(obj, comment)
      pp_object(obj, comment, verbose?)
    end

    def noisy_pp(obj, comment)
      pp_object(obj, comment, noisy?)
    end

    def url_for_object(object_name, assessment_id)
      URLS[object_name.to_sym].call(assessment_id)
    end
  end
end
