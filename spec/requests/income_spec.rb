require 'rails_helper'

RSpec.describe IncomesController, type: :request do

  describe 'POST incomes' do
    let(:assessment) { double Assessment, id: '3d24c939-7c35-48a2-a45b-594485038371' }
    let(:request_payload) { { json_key: :json_value }.to_json }
    let(:response_payload) { { result: :ok }.to_json }

    context 'valid payload' do
      it 'returns http success' do
        service = double IncomeCreationService, response_payload: response_payload, http_status: 200
        expect(IncomeCreationService).to receive(:new).with(request_payload).and_return(service)

        post assessment_income_path(assessment), params: request_payload
        expect(response).to have_http_status(:success)
        expect(response.body).to eq response_payload
      end
    end

    context 'invalid payload' do
      it 'returns http unprocessable entity' do
        service = double IncomeCreationService, response_payload: response_payload, http_status: 422
        expect(IncomeCreationService).to receive(:new).with(request_payload).and_return(service)

        post assessment_income_path(assessment), params: request_payload
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to eq response_payload
      end
    end
  end
end
