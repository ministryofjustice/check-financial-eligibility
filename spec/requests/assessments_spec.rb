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

    subject { post assessments_path, params: params.to_json, headers: headers }

    before { subject }

    context 'valid payload' do
      context 'successful creation of record' do
        it 'returns http success' do
          expect(response).to have_http_status(:success)
        end

        it 'has a valid payload' do
          expected_response = {
            success: true,
            objects: [Assessment.last],
            errors: []
          }.to_json
          expect(parsed_response).to eq JSON.parse(expected_response, symbolize_names: true)
        end
      end

      context 'Active Record Error in service' do
        before do
          creation_service = double AssessmentCreationService, success?: false, errors: ['error creating record']
          allow(AssessmentCreationService).to receive(:call).and_return(creation_service)
          post assessments_path, params: params.to_json, headers: headers
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
    end

    context 'invalid payload' do
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
  end

  describe 'GET assessments/:assessment_id' do
    let(:assessment) { create :assessment, :with_everything }
    let(:manager) { double WorkflowManager }

    it 'calls the Workflow manager' do
      expect(WorkflowManager).to receive(:new).with(assessment.id, StandardWorkflow.workflow).and_return(manager)
      expect(manager).to receive(:call)
      get assessment_path(assessment.id)
      expect(response).to be_successful
    end

    it 'returns a result', :show_in_doc do
      get assessment_path(assessment.id)
      response_hash = JSON.parse(response.body)

      expect(response_hash['assessment_result']).to eq 'eligible'
      expect(response_hash['applicant']['passported']).to be true
      expect(response_hash['applicant']['age_in_years'] < 60).to be true

      capital = response_hash['capital']
      expect(capital['pensioner_capital_disregard']).to eq 0.0
      expect(capital['liquid_capital_items'].size).to eq 1
      expect(capital['total_non_liquid_capital']).to eq 0.0
      expect(capital['non_liquid_capital_items']).to be_empty

      property = capital['property']
      expect(property['total_mortgage_allowance']).to eq 100_000.0
      expect(property['additional_properties'].size).to eq 1
      expect(property['main_home']['main_home_equity_disregard']).to eq 100_000.0
    end
  end
end
