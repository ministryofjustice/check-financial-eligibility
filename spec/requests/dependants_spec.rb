require 'rails_helper'

RSpec.describe DependantsController, type: :request do
  describe 'POST dependants' do
    let(:assessment) { create :assessment }
    let(:dependants) { create_list :dependant, 2, assessment: assessment }
    let(:request_payload) { { foo: :bar }.to_json }

    subject { post assessment_dependants_path(assessment), params: request_payload }

    before { stub_call_to_json_schema }

    context 'valid payload' do
      before do
        service = double DependantsCreationService, success?: true, dependants: dependants
        expect(DependantsCreationService).to receive(:call).with(request_payload).and_return(service)
        subject
      end

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      it 'generates a valid response' do
        expect(parsed_response[:success]).to eq(true)
        expect(parsed_response[:errors]).to be_empty
        expect(parsed_response[:objects]).not_to be_empty
        expect(parsed_response[:objects].first[:id]).to eq(dependants.first.id)
      end
    end

    context 'invalid payload' do
      before do
        service = double DependantsCreationService, success?: false, errors: %w[error_1 error_2]
        expect(DependantsCreationService).to receive(:call).with(request_payload).and_return(service)
        subject
      end

      it 'returns http unprocessable entity' do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns error payload' do
        expect(parsed_response[:success]).to eq(false)
        expect(parsed_response[:objects]).to eq(nil)
        expect(parsed_response[:errors]).to match_array(%w[error_1 error_2])
      end
    end

    context 'empty payload' do
      before { subject }

      it 'returns http unprocessable entity' do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns error payload' do
        expect(parsed_response[:errors]).not_to be_empty
      end
    end
  end
end
