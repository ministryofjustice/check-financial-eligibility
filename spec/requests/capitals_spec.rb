require 'rails_helper'

RSpec.describe CapitalsController, type: :request do
  describe 'POST capital' do
    let(:assessment) { create :assessment }
    let(:capital) do
      {
        bank_accounts: attributes_for_list(:bank_account, 2),
        non_liquid_assets: attributes_for_list(:non_liquid_asset, 2)
      }
    end
    let(:params) { { foo: :bar }.to_json }

    subject { post assessment_capitals_path(assessment), params: params }

    before { stub_call_to_json_schema }

    context 'valid payload' do
      before do
        service = double CapitalsCreationService, success?: true, capital: capital
        expect(CapitalsCreationService).to receive(:call).with(params).and_return(service)
        subject
      end

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      it 'generates a valid response' do
        expect(parsed_response[:success]).to eq(true)
        expect(parsed_response[:errors]).to be_empty
        expect(parsed_response[:objects]).to eq(capital)
      end
    end

    context 'invalid payload' do
      before do
        service = double CapitalsCreationService, success?: false, errors: %w[error_1 error_2]
        expect(CapitalsCreationService).to receive(:call).with(params).and_return(service)
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
