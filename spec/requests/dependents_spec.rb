require 'rails_helper'

RSpec.describe DependentsController, type: :request do
  describe 'POST dependents' do
    let(:assessment) { double Assessment, id: '3d24c939-7c35-48a2-a45b-594485038371' }
    let(:request_payload) { { json_key: :json_value }.to_json }
    let(:response_payload) { { result: :ok }.to_json }

    before { stub_call_to_get_json_schema }

    context 'valid payload' do
      before do
        service = double DependentsCreationService, success?: true, assessment: assessment
        expect(DependentsCreationService).to receive(:new).with(request_payload).and_return(service)
        post assessment_dependents_path(assessment), params: request_payload
      end

      let(:service) { double DependentsCreationService, success?: true, assessment: assessment }

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      it 'generates a valid response' do
        expect(response.body).to eq({ status: :ok, assessment_id: assessment.id }.to_json)
      end
    end

    context 'invalid payload' do
      before do
        service = double DependentsCreationService, success?: false, errors: %w[error_1 error_2]
        expect(DependentsCreationService).to receive(:new).with(request_payload).and_return(service)
        post assessment_dependents_path(assessment), params: request_payload
      end

      it 'returns http unprocessable entity' do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns error payload' do
        expect(response.body).to eq({ status: :error, errors: %w[error_1 error_2] }.to_json)
      end
    end
  end
end
