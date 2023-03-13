require "rails_helper"
Dir[Rails.root.join("lib/integration_helpers/**/*.rb")].sort.each { |f| require f }

##### NOTE #####
#
# This spec can be run for just one worksheet, or with varying levels of verbosity with the
# executable bin/ispec, for example:
#
#     bin/ispec -r -vv -w NPE6-1
#
# Will force a refresh of all the spreadsheets, process only worksheet NPE6-1, and have verbosity level 2
# (show details of all payloads and responses)
#
#    bin/ispec -h # show help text
#
RSpec.describe "IntegrationTests::TestRunner", type: :request do
  let(:spreadsheet_title) { "CFE Integration Test V3" }
  let(:target_worksheet) { ENV["TARGET_WORKSHEET"] }
  let(:verbosity_level) { (ENV["VERBOSE"] || "0").to_i }
  let(:refresh) { (ENV["REFRESH"] || "false") }

  let(:spreadsheet_file) { Rails.root.join("tmp/integration_test_data.xlsx") }
  let(:spreadsheet) { Roo::Spreadsheet.open(spreadsheet_file.to_s) }
  let(:worksheet_names) { spreadsheet.sheets }
  let(:headers) { { "CONTENT_TYPE" => "application/json", "Accept" => "application/json;version=5" } }

  before { setup_test_data }

  describe "run integration_tests", :vcr do
    ispec_run = ENV["ISPEC_RUN"].present?

    if ispec_run
      it "processes all the tests on all the sheets" do
        failing_tests = []
        test_count = 0
        group_runner = TestCase::GroupRunner.new(verbosity_level, refresh)
        group_runner.each do |worksheet|
          next if target_worksheet.nil? && worksheet.skippable?
          next if target_worksheet.present? && target_worksheet != worksheet.worksheet_name

          test_count += 1
          puts ">>> RUNNING TEST #{worksheet.description} <<<".yellow unless silent?
          pass = run_test_case(worksheet)
          failing_tests << worksheet.description unless pass
          result_message(failing_tests, test_count) unless silent?
        end
        expect(failing_tests).to be_empty, "Failing tests: #{failing_tests.join(', ')}"
      end
    elsif ENV["GOOGLE_SHEETS_PRIVATE_KEY_ID"].present?
      TestCase::GroupRunner.new(0, "false").each do |worksheet|
        next if worksheet.skippable?

        it "#{worksheet.description} passes" do
          pass = run_test_case(worksheet)
          expect(pass).to be true
        end
      end
    end

    def result_message(failing_tests, test_count)
      if failing_tests.empty?
        puts "#{test_count} tests run successfully".green
      else
        puts "#{failing_tests.size} tests failed out of #{test_count}".red
        failing_tests.each { |t| puts " >> #{t}".red }
      end
    end

    def run_test_case(worksheet)
      worksheet.parse_worksheet
      payloads_hash = worksheet.payload_objects.reject(&:blank?).map { |obj| [obj.url_method, obj.payload] }.to_h
      assessment_id = post_assessment(worksheet)
      payloads_hash.each do |url_method, payload|
        url = Rails.application.routes.url_helpers.__send__(url_method, assessment_id)
        noisy_post(url, payload, worksheet.version)
      end
      v1_api_results = get_assessment(assessment_id, worksheet.version)
      worksheet.compare_results(v1_api_results)
      url_method_mapping = {
        assessment_capitals_path: :capitals,
        assessment_cash_transactions_path: :cash_transactions,
        assessment_irregular_incomes_path: :irregular_incomes,
      }
      v2_payloads = payloads_hash.map do |url_method, payload|
        if url_method_mapping.key? url_method
          { url_method_mapping.fetch(url_method) => payload }
        else
          payload
        end
      end
      v2_payload = v2_payloads.reduce(assessment: worksheet.assessment.payload) { |hash, elem| hash.merge(elem) }
      v2_api_results = noisy_post("/v2/assessments", v2_payload, worksheet.version)
      puts Hashdiff.diff(*[v1_api_results, v2_api_results].map { |x| remove_result_noise(x) })
      worksheet.compare_results(v2_api_results)
    end

    def remove_result_noise(api_results)
      api_results.except(:timestamp).merge(assessment: api_results.fetch(:assessment).except(:id))
    end

    def get_assessment(assessment_id, version)
      puts ">>>>>>>>>>>> #{assessment_path(assessment_id)} #{__FILE__}:#{__LINE__} <<<<<<<<<<<<".yellow unless silent?
      get assessment_path(assessment_id), headers: headers(version)
      pp parsed_response if noisy?
      raise "Unsuccessful response" unless parsed_response[:success]

      parsed_response
    end

    def noisy_post(url, payload, version)
      puts ">>>>>>>>>>>> #{url} V#{version} #{__FILE__}:#{__LINE__} <<<<<<<<<<<<".yellow unless silent?
      pp payload if noisy?
      post url, params: payload.to_json, headers: headers(version)
      pp parsed_response if noisy?
      puts " \n" if noisy?
      raise "Unsuccessful response: #{parsed_response.inspect}" unless parsed_response[:success]

      parsed_response
    end

    def post_assessment(worksheet)
      url = worksheet.assessment.url
      payload = worksheet.assessment.payload
      noisy_post url, payload, worksheet.version
      parsed_response[:assessment_id]
    end

    def silent?
      verbosity_level == 0
    end

    def noisy?
      verbosity_level == 2
    end

    def headers(version)
      { "CONTENT_TYPE" => "application/json", "Accept" => "application/json;version=#{version}" }
    end

    def setup_test_data
      create :bank_holiday
      Dibber::Seeder.new(StateBenefitType, "data/state_benefit_types.yml", name_method: :label, overwrite: true).build
    end
  end
end
