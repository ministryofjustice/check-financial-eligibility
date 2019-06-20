require 'rails_helper'

RSpec.describe IncomesController, type: :request do
  describe 'POST incomes' do
    let(:assessment) { double Assessment, id: '3d24c939-7c35-48a2-a45b-594485038371' }
    let(:dummy_payload) { { json_key: :json_value }.to_json }

    context 'valid payload' do
      let(:success_response) { ApiResponse.success(%i[rec_1 rec_2]) }

      before do
        expect(IncomeCreationService).to receive(:call).with(dummy_payload).and_return(success_response)
        post assessment_income_path(assessment), params: dummy_payload
      end

      it 'returns https status success' do
        expect(response).to have_http_status(:success)
      end

      it 'returns expected response' do
        expect(response.body).to eq({ success: true, objects: %i[rec_1 rec_2], errors: [] }.to_json)
      end
    end

    context 'invalid payload' do
      let(:error_response) { ApiResponse.error(%i[error_1 error_2]) }

      before do
        expect(IncomeCreationService).to receive(:call).with(dummy_payload).and_return(error_response)
        post assessment_income_path(assessment), params: dummy_payload
      end

      it 'returns https status 422' do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns expected response' do
        expect(response.body).to eq({ success: false, objects: nil, errors: %i[error_1 error_2] }.to_json)
      end
    end
  end
end
