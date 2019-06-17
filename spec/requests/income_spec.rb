require 'rails_helper'

RSpec.describe IncomesController, type: :request do
  describe 'POST incomes' do
    let(:assessment) { double Assessment, id: '3d24c939-7c35-48a2-a45b-594485038371' }
    let(:request_payload) { { json_key: :json_value }.to_json }
    let(:response_payload) { { result: :ok }.to_json }

    context 'valid payload' do
      before do
        service = double IncomeCreationService, success?: true, assessment: assessment
        expect(IncomeCreationService).to receive(:new).with(request_payload).and_return(service)
        post assessment_income_path(assessment), params: request_payload
      end

      it 'returns https status success' do
        expect(response).to have_http_status(:success)
      end

      it 'returns expected response' do
        expect(response.body).to eq({ status: :ok, assessment_id: assessment.id }.to_json)
      end
    end

    context 'invalid payload' do
      before do
        service = double IncomeCreationService, success?: false, errors: ['xxx']
        expect(IncomeCreationService).to receive(:new).with(request_payload).and_return(service)
        post assessment_income_path(assessment), params: request_payload
      end

      it 'returns https status 422' do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns expected response' do
        expect(response.body).to eq({ status: :error, errors: ['xxx'] }.to_json)
      end
    end
  end
end
