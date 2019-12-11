require 'rails_helper'

RSpec.describe AssessmentsController, type: :request do
  describe 'POST assessments' do
    let(:params) do
      {
        client_reference_id: 'psr-123',
        submission_date: '2019-06-06',
        matter_proceeding_type: 'domestic_abuse'
      }
    end
    let(:headers) { { 'CONTENT_TYPE' => 'application/json' } }
    let(:before_request) { nil }

    subject { post assessments_path, params: params.to_json, headers: headers }

    before do
      before_request
      subject
    end

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end

    it 'has a valid payload', :show_in_doc do
      expected_response = {
        success: true,
        objects: [Assessment.last],
        errors: []
      }.to_json
      expect(parsed_response).to eq JSON.parse(expected_response, symbolize_names: true)
    end

    context 'Active Record Error in service' do
      let(:before_request) do
        creation_service = double Creators::AssessmentCreator, success?: false, errors: ['error creating record']
        allow(Creators::AssessmentCreator).to receive(:call).and_return(creation_service)
      end

      it 'returns http unprocessable_entity' do
        expect(response).to have_http_status(422)
      end

      it 'returns error json payload', :show_in_doc do
        expected_response = {
          errors: ['error creating record'],
          success: false
        }
        expect(parsed_response).to eq expected_response
      end
    end

    context 'invalid matter proceeding type' do
      let(:params) { { matter_proceeding_type: 'xxx', submission_date: '2019-07-01' } }

      it_behaves_like 'it fails with message', %(Invalid parameter 'matter_proceeding_type' value "xxx": Must be one of: <code>domestic_abuse</code>.)
    end

    context 'missing submission date' do
      let(:params) do
        {
          matter_proceeding_type: 'domestic_abuse',
          client_reference_id: 'psr-123'
        }
      end

      it_behaves_like 'it fails with message', 'Missing parameter submission_date'
    end
  end

  describe 'GET /assessments/:id' do
    let(:assessment) { create :assessment, :with_applicant }
    let(:option) { :below_lower_threshold }
    let!(:capital_summary) { create :capital_summary, option, assessment: assessment }
    let!(:non_liquid_capital_item) { create :non_liquid_capital_item, capital_summary: capital_summary }
    let!(:liquid_capital_item) { create :liquid_capital_item, capital_summary: capital_summary }
    let!(:main_home) { create :property, :main_home, capital_summary: capital_summary }
    let!(:property) { create :property, :additional_property, capital_summary: capital_summary }
    let!(:vehicle) { create :vehicle, capital_summary: capital_summary }

    subject { get assessment_path(assessment) }

    before do
      assessment.capital_summary.summarise!
      assessment.determine_result!
      assessment.reload
      subject
    end

    it 'returns http success', :show_in_doc do
      expect(response).to have_http_status(:success)
    end

    it 'returns capital summary data as json' do
      expect(parsed_response).to eq(JSON.parse(Decorators::ResultDecorator.new(assessment).to_json, symbolize_names: true))
    end
  end
end
