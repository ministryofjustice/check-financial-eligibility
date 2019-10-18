require 'rails_helper'

RSpec.describe IntegrationTests::TestRunner, type: :request do
  let(:spreadsheet_file) { Rails.root.join('spec/fixtures/integration_test_data.xlsx') }
  let(:spreadsheet) { Roo::Spreadsheet.open(spreadsheet_file.to_s) }
  let(:worksheet_names) { spreadsheet.sheets.select { |name| name.starts_with?('Test - ') } }
  let(:headers) { { 'CONTENT_TYPE' => 'application/json' } }

  describe '#steps' do
    def create_assessment(payload)
      post assessments_path, params: payload[:assessment].to_json, headers: headers
      JSON.parse(response.body)['objects'].first['id']
    end

    def post_resource(url, params)
      post url, params: params.to_json, headers: headers
      expect(response).to be_successful
      expect(JSON.parse(response.body)['success']).to eq true
    end

    def fetch_result(assessment_id)
      get assessment_path(assessment_id), headers: headers
      JSON.parse(response.body, symbolize_names: true)
    end

    def verbose_output(test_pass, result, payload, spreadsheet_name)
      puts commentary(result, payload, spreadsheet_name)
      puts test_pass ? '**** Passed ****'.green : '**** Failed ****'.red
    end

    def commentary(result, payload, spreadsheet_name)
      <<-TEXT
      ---------
      #{spreadsheet_name}
      actual <-> expected
      #{result[:assessment_result]} <-> #{payload[:expected_results][:overall_result]}
      total_capital : #{result[:capital][:total_capital]} <-> #{payload[:expected_results][:applicant_disposable_capital]}
      capital_contribution: #{result[:capital][:capital_contribution]} <-> #{payload[:contribution_results][:from_capital]}
      TEXT
    end

    def compare_result(assessment_id, payload, spreadsheet_name)
      result = fetch_result(assessment_id)
      test_pass = result_as_expected?(result, payload)
      verbose_output(test_pass, result, payload, spreadsheet_name) if ENV['VERBOSE'] == 'true'
      test_pass
    end

    def result_as_expected?(result, payload)
      result[:assessment_result] == payload[:expected_results][:overall_result] &&
        result[:capital][:total_capital] == payload[:expected_results][:applicant_disposable_capital].to_s &&
        result[:capital][:capital_contribution] == payload[:contribution_results][:from_capital].to_s
    end

    def run_spreadsheet(spreadsheet_name)
      payload = IntegrationTests::WorksheetParser.call(spreadsheet.sheet(spreadsheet_name))

      assessment_id = create_assessment(payload)
      described_class.steps(assessment_id, payload).each do |step|
        post_resource(step.url, step.params) if step.params.present?
      end
      compare_result(assessment_id, payload, spreadsheet_name)
    end

    it 'process all worksheets and does not raise any error' do
      results = []
      worksheet_names.each do |spreadsheet_name|
        results << run_spreadsheet(spreadsheet_name)
      end
      expect(results.uniq == [true]).to be_truthy, 'Integration test fail: run `rake integration` to see details of results mismatch'
    end
  end
end
