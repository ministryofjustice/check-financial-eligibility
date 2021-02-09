require 'rails_helper'
Dir[Rails.root.join('lib/integration_helpers/**/*.rb')].sort.each { |f| require f }

##### NOTE #####
#
# This spec can be run for just one worksheet, or with varying levels of verbosity with the
# executable bin/ispec, for example:
#
#     bin/ispec -r -vv -w NPE6-1
#
# Will force a refresh of the spreadsheet, process only worksheet NPE6-1, and have verbosity level 2
# (show details of all payloads and responses)
#

RSpec.describe 'IntegrationTests::TestRunner', type: :request do
  # let(:spreadsheet_title) { 'New means assessment test data' }
  let(:spreadsheet_title) { 'Copy of New means assessment test data' }


  let(:spreadsheet_file) { Rails.root.join('tmp/integration_test_data.xlsx') }
  let(:spreadsheet) { Roo::Spreadsheet.open(spreadsheet_file.to_s) }
  let(:worksheet_names) { spreadsheet.sheets }
  let(:headers) { { 'CONTENT_TYPE' => 'application/json', 'Accept' => 'application/json;version=3' } }
  let(:target_worksheet) { ENV['TARGET_WORKSHEET'] }
  let(:verbosity_level) { (ENV['VERBOSE'] || '0').to_i }

  before { setup_test_data }

  describe 'run integration_tests' do
    it 'passes all tests' do
      failing_tests = []
      worksheet_names.each do |worksheet_name|
        next if target_worksheet.present? && worksheet_name != target_worksheet

        test_case = TestCase::Worksheet.new(spreadsheet, worksheet_name, verbosity_level)
        next if test_case.skippable?
        puts ">>> RUNNING TEST #{worksheet_name} <<<".yellow unless silent?
        pass = run_test_case(test_case)
        failing_tests << worksheet_name unless pass
      end
      expect(failing_tests).to be_empty, "Failing tests: #{failing_tests.join(', ')}"
    end

    def run_test_case(test_case)
      test_case.parse_worksheet
      assessment_id = post_assessment(test_case)

      test_case.payload_objects.each { |obj| post_object(obj, assessment_id) }
      actual_results = get_assessment(assessment_id)
      test_case.compare_results(actual_results)
    end

    def get_assessment(assessment_id)
      puts ">>>>>>>>>>>> #{assessment_path(assessment_id)} #{__FILE__}:#{__LINE__} <<<<<<<<<<<<".yellow unless silent?
      get assessment_path(assessment_id), headers: headers
      pp parsed_response if noisy?
      raise 'Unsuccessful response' unless parsed_response[:success]

      parsed_response
    end

    def noisy_post(url, payload)
      puts ">>>>>>>>>>>> #{url} #{__FILE__}:#{__LINE__} <<<<<<<<<<<<".yellow unless silent?
      pp payload if noisy?
      post url, params: payload.to_json, headers: headers
      pp parsed_response if noisy?
      puts " \n" if noisy?
      raise "Unsuccessful response: #{parsed_response.inspect}" unless parsed_response[:success]

      parsed_response
    end

    def post_assessment(test_case)
      url = test_case.assessment.url
      payload = test_case.assessment.payload
      noisy_post url, payload
      parsed_response[:assessment_id]
    end

    def post_object(obj, assessment_id)
      return if obj.nil?


      url_method = obj.__send__(:url_method)
      url = Rails.application.routes.url_helpers.__send__(url_method, assessment_id)
      payload = obj.__send__(:payload)
      noisy_post(url, payload)
    end

    def compare_results(worksheet_name, actual_results_hash, expected_results_hash)
      actual_result = ActualResult.new(actual_results_hash)
      noisy_pp actual_result, 'ASSESSMENT RESULT'
      expected_result = ExpectedResult.new(worksheet_name, expected_results_hash)
      expected_result == actual_result
    end

    def silent?
      verbosity_level == 0
    end

    def noisy?
      verbosity_level == 2
    end

    # rubocop:disable Style/StringLiterals
    def google_secret
      {
        type: 'service_account',
        project_id: 'laa-apply-for-legal-aid',
        private_key_id: ENV['PRIVATE_KEY_ID'],
        private_key: ENV['PRIVATE_KEY'].gsub("\\n", "\n"),
        client_email: ENV['CLIENT_EMAIL'],
        client_id: ENV['CLIENT_ID'],
        auth_uri: 'https://accounts.google.com/o/oauth2/auth',
        token_uri: 'https://oauth2.googleapis.com/token',
        auth_provider_x509_cert_url: 'https://www.googleapis.com/oauth2/v1/certs',
        client_x509_cert_url: 'https://www.googleapis.com/robot/v1/metadata/x509/laa-apply-service%40laa-apply-for-legal-aid.iam.gserviceaccount.com'
      }
    end
    # rubocop:enable Style/StringLiterals

    def local_spreadsheet_needs_replacing?(local, remote)
      return true unless File.exist?(local)

      return true if ENV['REFRESH'] == 'true'

      remote.modified_time > File.mtime(local)
    end

    def setup_test_data
      create :bank_holiday
      Dibber::Seeder.new(StateBenefitType, 'data/state_benefit_types.yml', name_method: :label, overwrite: true).build

      secret_file = StringIO.new(google_secret.to_json)
      session = GoogleDrive::Session.from_service_account_key(secret_file)
      google_sheet = session.spreadsheet_by_title(spreadsheet_title)
      return unless local_spreadsheet_needs_replacing?(spreadsheet_file, google_sheet)

      puts 'Refreshing spreadsheet'
      google_sheet.export_as_file('tmp/integration_test_data.xlsx', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
    end
  end
end
