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
  let(:spreadsheet_file) { Rails.root.join('spec/fixtures/integration_test_data.xlsx') }
  let(:spreadsheet) { Roo::Spreadsheet.open(spreadsheet_file.to_s) }
  let(:worksheet_names) { spreadsheet.sheets }
  let(:headers) { { 'CONTENT_TYPE' => 'application/json', 'Accept' => 'application/json;version=2' } }
  let(:target_worksheet) { ENV['TARGET_WORKSHEET'] }
  # let(:target_worksheet) { 'NPE9-2' }

  before do
    Dibber::Seeder.new(StateBenefitType, 'data/state_benefit_types.yml', name_method: :label, overwrite: true).build
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
        datasets.keys.each do |object_name|
          post_object(assessment_id, datasets, object_name)
        end
        get assessment_path(assessment_id), headers: headers
        expected_results = ExpectedResultsExtractor.new(spreadsheet, worksheet_name).run
        results[worksheet_name] = compare_results(parsed_response, expected_results)
      end
      expect(results).to show_all_integration_tests_passed
    end

    def compare_results(actual_results_hash, expected_results_hash)
      actual_result = ActualResult.new(actual_results_hash)
      noisy_pp actual_result, 'ASSESSMENT RESULT'
      expected_result = ExpectedResult.new(expected_results_hash)
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
