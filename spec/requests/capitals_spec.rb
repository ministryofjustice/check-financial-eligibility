require 'rails_helper'

RSpec.describe CapitalsController, type: :request do
  describe 'POST capital' do
    let(:assessment) { create :assessment }
    let(:assessment_id) { assessment.id }
    let(:bank_accounts) { attributes_for_list(:bank_account, 2) }
    let(:non_liquid_capital) { attributes_for_list(:non_liquid_asset, 2) }
    let(:params) do
      {
        liquid_capital: { bank_accounts: bank_accounts },
        non_liquid_capital: non_liquid_capital
      }
    end
    let(:headers) { { 'CONTENT_TYPE' => 'application/json' } }

    subject { post assessment_capitals_path(assessment_id), params: params.to_json, headers: headers }

    before { subject }

    context 'valid payload' do
      context 'with both types of assets' do
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
        let(:params) do
          {
            liquid_capital: { bank_accounts: bank_accounts }
          }
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
        let(:params) do
          {
            non_liquid_capital: non_liquid_capital
          }
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
        let(:assessment_id) { SecureRandom.uuid }

        it 'errors and is shown in apidocs', :show_in_doc do
          expect(response).to have_http_status(422)
        end

        it_behaves_like 'it fails with message', 'No such assessment id'
      end
    end

    context 'invalid payload' do
      context 'missing bank account on liquid capital' do
        let(:params) do
          {
            liquid_capital: {}
          }
        end

        it_behaves_like 'it fails with message', 'Missing parameter bank_accounts'
      end

      context 'missing name on bank account' do
        let(:bank_accounts) { attributes_for_list(:bank_account, 2).map { |account| account.tap { |item| item.delete(:name) } } }
        it_behaves_like 'it fails with message', 'Missing parameter name'
      end

      context 'missing lowest balance on bank account' do
        let(:bank_accounts) { attributes_for_list(:bank_account, 2).map { |account| account.tap { |item| item.delete(:lowest_balance) } } }
        it_behaves_like 'it fails with message', 'Missing parameter lowest_balance'
      end

      context 'missing description on non_liquid capital' do
        let(:non_liquid_capital) { attributes_for_list(:non_liquid_asset, 2).map { |nlc| nlc.tap { |item| item.delete(:description) } } }
        it_behaves_like 'it fails with message', 'Missing parameter description'
      end

      context 'missing value on non-liquid capital' do
        let(:non_liquid_capital) { attributes_for_list(:non_liquid_asset, 2).map { |nlc| nlc.tap { |item| item.delete(:value) } } }
        it_behaves_like 'it fails with message', 'Missing parameter value'
      end
    end
  end
end
