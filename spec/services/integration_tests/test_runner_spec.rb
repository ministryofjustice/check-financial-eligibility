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

    def run_spreadsheet(spreadsheet_name)
      payload = IntegrationTests::WorksheetParser.call(spreadsheet.sheet(spreadsheet_name))
      assessment_id = create_assessment(payload)
      described_class.steps(assessment_id, payload).each do |step|
        post_resource(step.url, step.params) if step.params.present?
      end
    end

    it 'process all worksheets and does not raise any error' do
      worksheet_names.each do |spreadsheet_name|
        run_spreadsheet(spreadsheet_name)
        # TODO: fetch result and make sure if matches what is expected
      end
    end
  end
end
