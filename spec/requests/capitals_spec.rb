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
        it 'returns http success', :show_in_doc do
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

      context 'empty payload' do
        let(:params) { {} }

        before { post assessment_capitals_path(assessment), params: params.to_json, headers: headers }

        it 'returns http unprocessable entity' do
          expect(response).to have_http_status(:success)
        end

        it 'returns error payload' do
          expect(parsed_response[:success]).to eq(true)
          expect(parsed_response[:errors]).to be_empty
          expect(parsed_response[:objects][:bank_accounts]).to be_empty
          expect(parsed_response[:objects][:non_liquid_assets]).to be_empty
        end
      end

      context 'Active Record error' do
        before do
          params[:assessment_id] = SecureRandom.uuid
          post assessment_capitals_path(assessment), params: params.to_json, headers: headers
        end

        it 'errors and is shown in apidocs', :show_in_doc do
          expect(response).to have_http_status(422)
        end

        it_behaves_like 'it fails with message', 'No such assessment id'
      end
    end

    context 'invalid payload' do
      context 'missing bank account on liquid capital' do
        before do
          params[:liquid_capital] = {}
          post assessment_capitals_path(assessment), params: params.to_json, headers: headers
        end

        it_behaves_like 'it fails with message', 'Missing parameter bank_accounts'
      end

      context 'missing name on bank account' do
        before do
          params[:liquid_capital][:bank_accounts].first.delete(:name)
          post assessment_capitals_path(assessment), params: params.to_json, headers: headers
        end
        it_behaves_like 'it fails with message', 'Missing parameter name'
      end

      context 'missing lowest balance on bank account' do
        before do
          params[:liquid_capital][:bank_accounts].first.delete(:lowest_balance)
          post assessment_capitals_path(assessment), params: params.to_json, headers: headers
        end
        it_behaves_like 'it fails with message', 'Missing parameter lowest_balance'
      end

      context 'missing description on non_liquid capital' do
        before do
          params[:non_liquid_capital].first.delete(:description)
          post assessment_capitals_path(assessment), params: params.to_json, headers: headers
        end
        it_behaves_like 'it fails with message', 'Missing parameter description'
      end

      context 'missing value on non-liquid capital' do
        before do
          params[:non_liquid_capital].first.delete(:value)
          post assessment_capitals_path(assessment), params: params.to_json, headers: headers
        end
        it_behaves_like 'it fails with message', 'Missing parameter value'
      end
    end
  end
end
