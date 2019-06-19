require 'rails_helper'

RSpec.describe DependentsController, type: :request do
  describe 'POST dependents' do
    let(:assessment) { create :assessment }
    let(:dependents) { create_list :dependent, 2, assessment: assessment }
    let(:request_payload) { { foo: :bar }.to_json }

    subject { post assessment_dependents_path(assessment), params: request_payload }

    before { stub_call_to_get_json_schema }

    context 'valid payload' do
      before do
        service = double DependentsCreationService, success?: true, dependents: dependents
        expect(DependentsCreationService).to receive(:call).with(request_payload).and_return(service)
        subject
      end

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      it 'generates a valid response' do
        expect(json[:success]).to eq(true)
        expect(json[:errors]).to be_empty
        expect(json[:objects]).not_to be_empty
        expect(json[:objects].first[:id]).to eq(dependents.first.id)
      end
    end

    context 'invalid payload' do
      before do
        service = double DependentsCreationService, success?: false, errors: %w[error_1 error_2]
        expect(DependentsCreationService).to receive(:call).with(request_payload).and_return(service)
        subject
      end

      it 'returns http unprocessable entity' do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns error payload' do
        expect(json[:success]).to eq(false)
        expect(json[:objects]).to eq(nil)
        expect(json[:errors]).to match_array(%w[error_1 error_2])
      end
    end

    context 'empty payload' do
      before { subject }

      it 'returns http unprocessable entity' do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns error payload' do
        expect(json[:errors]).not_to be_empty
      end
    end
  end
end
