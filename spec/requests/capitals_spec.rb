require 'rails_helper'

RSpec.describe CapitalsController, type: :request do
  describe 'POST capital' do
    let(:assessment) { create :assessment }
    let(:params) do
      {
        assessment_id: assessment.id,
        liquid_capital: {
          bank_accounts: attributes_for_list(:bank_account, 2)
        },
        non_liquid_capital: attributes_for_list(:non_liquid_asset, 2)
      }
    end
    let(:headers) { { 'CONTENT_TYPE' => 'application/json' } }

    context 'valid payload' do
      context 'with both types of assets' do
        before { post assessment_capitals_path(assessment), params: params.to_json, headers: headers }
        it 'returns http success' do
          expect(response).to have_http_status(:success)
        end

        it 'generates a valid response' do
          expect(parsed_response[:success]).to eq(true)
          expect(parsed_response[:errors]).to be_empty
          expect(parsed_response[:objects][:bank_accounts].size).to eq 2
          expect(parsed_response[:objects][:non_liquid_assets].size).to eq 2
        end
      end

      context 'with only bank accounts' do
        before do
          params.delete(:non_liquid_capital)
          post assessment_capitals_path(assessment), params: params.to_json, headers: headers
        end

        it 'returns http success' do
          expect(response).to have_http_status(:success)
        end

        it 'generates a valid response' do
          expect(parsed_response[:success]).to eq(true)
          expect(parsed_response[:errors]).to be_empty
          expect(parsed_response[:objects][:bank_accounts].size).to eq 2
          expect(parsed_response[:objects][:non_liquid_assets]).to be_empty
        end
      end

      context 'with only non-liquid assets' do
        before do
          params.delete(:liquid_capital)
          post assessment_capitals_path(assessment), params: params.to_json, headers: headers
        end

        it 'returns http success' do
          expect(response).to have_http_status(:success)
        end

        it 'generates a valid response' do
          expect(parsed_response[:success]).to eq(true)
          expect(parsed_response[:errors]).to be_empty
          expect(parsed_response[:objects][:bank_accounts]).to be_empty
          expect(parsed_response[:objects][:non_liquid_assets].size).to eq 2
        end
      end
    end

    context 'invalid payload' do
      context 'empty payload' do
        before { post assessment_capitals_path(assessment), params: "".to_json, headers: headers }

        it 'returns http unprocessable entity' do
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'returns error payload' do
          puts ">>>>>>>>>  #{__FILE__}:#{__LINE__} <<<<<<<<<<\n"

          ap parsed_response
          expect(parsed_response[:errors]).not_to be_empty
        end
      end
    end
  end
end
