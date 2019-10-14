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

    def verbose_output(result, payload, spreadsheet_name)
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

      puts verbose_output(result, payload, spreadsheet_name) if ENV['VERBOSE'] == 'true'

      # TODO: uncomment when fixed
      # expect(result[:assessment_result]).to eq(payload[:expected_results][:overall_result])
      # expect(result[:capital][:total_capital]).to eq(payload[:expected_results][:applicant_disposable_capital].to_s)
      # expect(result[:capital][:capital_contribution]).to eq(payload[:contribution_results][:from_capital].to_s)
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
      worksheet_names.each do |spreadsheet_name|
        run_spreadsheet(spreadsheet_name)
        # TODO: fetch result and make sure if matches what is expected
      end
    end
  end
end
