require 'rails_helper'

RSpec.describe AssessmentsController, type: :request do
  describe 'POST assessments' do
    let(:request_payload) { { json_key: :json_value }.to_json }
    let(:remote_ip) { '127.0.0.1' }
    let(:response_payload) { { result: :ok }.to_json }

    context 'valid payload' do
      it 'returns http success' do
        service = double AssessmentService, response_payload: response_payload, http_status: 200
        expect(AssessmentService).to receive(:new).with(remote_ip, request_payload).and_return(service)
        expect(service).to receive(:call)

        post assessments_path, params: request_payload
        expect(response).to have_http_status(:success)
        expect(response.body).to eq response_payload
      end
    end

    context 'invalid payload' do
      it 'returns http unprocessable entity' do
        service = double AssessmentService, response_payload: response_payload, http_status: 422
        expect(AssessmentService).to receive(:new).with(remote_ip, request_payload).and_return(service)
        expect(service).to receive(:call)

        post assessments_path, params: request_payload
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to eq response_payload
      end
    end
  end
end
